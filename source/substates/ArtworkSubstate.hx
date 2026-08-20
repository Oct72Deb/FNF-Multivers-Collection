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

class ArtworkSubstate extends FlxSubState {
    
    private var _pressingPractice:Bool = false;
    private var _pressingBot:Bool = false;

    // UI
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
    private var curIndex:Int = 0;
    public var currentWeek:String;

    // Valeurs d'initialisation transmises par FreeplayState via le constructeur
    // (create() est différé, on ne peut pas appeler updateArtworkForSong avant)
    private var _initSongName:String = "";
    private var _initDifficulty:Int = 1;

    // Difficulty — géré uniquement par FreeplayState via setDifficulty()
    var currentDifficulty:Int = 1;
    var currentDifficultyName:String = "normal"; // Nom de la difficulté courante (lowercase)

    // ---------- BOX CONFIG ----------
    var scaleBox:Float = 0.4;    
    var clickMargin:Float = 8;  
    var labelOffsetX:Float = 32; 
    var labelOffsetY:Float = 0;
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

    static var artworks:Array<{path:String, text:String, desc:String, difficulties:Array<Int>, diffLabels:Array<String>, difficultyArtworks:Map<String, String>, difficultyTexts:Map<String, String>, difficultyDescs:Map<String, String>, ?difficultyValues:Map<String, Int>}> =
    [

        {   path: "artworks/placeholder",        text: "???",
            desc: "???Dummy_placeholder???",
            difficulties: [0,0,0],          diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/HOW_TO_PLAY",        text: "Don't know how to play? No problem! The Mario Bros. are here for you!",
            desc: "BPM: 124 / VS. Mario Bros.",
            difficulties: [2,6,10,17,20],    diffLabels: ["VeryEasy", "Easy", "Normal", "Hard", "Veryhard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/HOW_TO_PLAY",        text: "An opponent who reflects mystery...",
            desc: "BPM: 120 / VS. Metal Mario",
            difficulties: [0,4,8,12,20],    diffLabels: ["VeryEasy", "Easy", "Normal", "Hard", "Veryhard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/targets",            text: "Ayuwoki ?",
            desc: "BPM: 118 / BONUS STAGE",
            difficulties: [0,0,0],           diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/puff",               text: "A little pink ball crashing out on a fox to the beat.",
            desc: "BPM: 180 / VS. FUCKING Fox McCloud",
            difficulties: [3,6,10],          diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/HOW_TO_PLAY",        text: "A candy hunt connected to the real world.",
            desc: "BPM: 125 > 145 > 210 > 145 / VS. ???",
            difficulties: [3,6,10],          diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/placeholder",        text: "A candy shitshow connected to a parallel universe.",
            desc: "BPM: 140 / VS. ???",
            difficulties: [3,6,10],          diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/placeholder",            text: "BF who wouldn't even reach his ankle.",
            desc: "BPM: 147 > ??? / VS. Isabelle",
            difficulties: [3,7,12],          diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/star",               text: "Fly to the stars to the sound of her voice.",
            desc: "BPM: 173 / VS. Océane",
            difficulties: [3,7,12],          diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/scarymacron",        text: "Fight it out in beeps and boops without getting overruled.",
            desc: "BPM: 155 / VS. Emmanuel Macron",
            difficulties: [6,10,20],         diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },

        {   path: "artworks/SilvaGunner_Banner", text: "???",
            desc: "BPM: 180 / VS. Gangsta Mario",
            difficulties: [6,10,15],         diffLabels: ["Easy", "Normal", "Hard", "Pico-mix", "B-side", "Corruption", "Minus", "In-game-version", "In-game-mix"],
            difficultyArtworks: ["erect" => "artworks/epicrap", "nightmare" => "artworks/epicrap", "in-game-version" => "artworks/SilvaGunner_Banner_igv", "in-game-mix" => "artworks/SilvaGunner_Banner_igm", "corruption" => "artworks/SilvaGunner_Banner_corruption"],
            difficultyTexts:    ["erect" => "Version Erect !"],
            difficultyDescs:    ["erect" => "BPM: 180 / VS Gangsta Mario (Erect)"],
            // TODO: valeurs a ajuster selon le vrai ressenti de diff de chaque variante (prototype)
            difficultyValues:   ["erect" => 18, "nightmare" => 20, "pico-mix" => 12, "b-side" => 14,
                                  "corruption" => 16, "minus" => 8, "in-game-version" => 10, "in-game-mix" => 11], },

        {   path: "artworks/new_game",           text: "Mario get you next time!",
            desc: "BPM: 145 / VS. Super Horror Mario",
            difficulties: [5,10,15],         diffLabels: ["Easy", "Normal", "Hard"],
            difficultyArtworks: null,        difficultyTexts: null,        difficultyDescs: null },
    ];

    override function create() {
        super.create();

        bg = new FlxSprite(Std.int(FlxG.width * 0.65), 0)
            .makeGraphic(Std.int(FlxG.width * 0.35), FlxG.height, FlxColor.fromRGB(0, 0, 0, 0));
        add(bg);

        artImage = new FlxSprite(bg.x + 60, 180);
        add(artImage);

        barMaxWidth = Std.int(bg.width - 120);

        barBg = new FlxSprite(bg.x + 45, 100)
            .makeGraphic(barMaxWidth, 20, FlxColor.fromRGB(40, 40, 40));
        add(barBg);

        barFill = new FlxSprite(bg.x + 45, 100)
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

        var baseX:Float = bg.x + 40;
        var baseY:Float = bg.y + 580;
        var gapY:Float = 56;
        var id:Int = 0;
        for (opt in optionsArray) {
            if (opt.type == "bool") {
                var cb:CheckboxThingie = new CheckboxThingie(0, 0, opt.getValue() == true);
                cb.x = baseX;
                cb.y = baseY + id * gapY;
                cb.scale.set(scaleBox, scaleBox);
                setCheckboxVisual(cb, cb.daValue);
                cb.updateHitbox();
                cb.ID = id;
                checkboxGroup.add(cb);

                var lbl:FlxText = new FlxText(0, 0, 300, opt.name);
                lbl.setFormat(null, 16, FlxColor.WHITE, "left");
                lbl.x = cb.x + (cb.width * cb.scale.x) + labelOffsetX;
                lbl.y = cb.y + (cb.height * cb.scale.y - lbl.size) / 2 + labelOffsetY;
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

        // FIX 3 — On utilise les valeurs passées au constructeur par FreeplayState
        // (_initSongName / _initDifficulty) plutôt que PlayState.SONG.song.
        // openSubState() diffère create() au prochain tick, donc FreeplayState ne peut
        // pas appeler updateArtworkForSong() après openSubState() : artImage serait null.
        // Le constructeur reçoit les bonnes valeurs, et create() les applique ici,
        // quand tous les sprites sont initialisés.
        if (_initSongName != "")
            updateArtworkForSong(_initSongName);
        setDifficulty(_initDifficulty);
    }

    function getOptions():Void {
        optionsArray = [];
        optionsArray.push(new ArtworkGameplayOption("Practice Mode", "practice", "bool", false));
        optionsArray.push(new ArtworkGameplayOption("Botplay", "botplay", "bool", false));
    }

    function setCheckboxVisual(cb:CheckboxThingie, value:Bool):Void {
        cb.animation.play(value ? "on" : "off");
        cb.animation.play(value ? "checked" : "unchecked");
    }

    function reloadCheckboxes():Void {
        for (cb in checkboxGroup) {
            var idx = cb.ID;
            if (idx >= 0 && idx < optionsArray.length) {
                var v = optionsArray[idx].getValue() == true;
                cb.daValue = v;
                setCheckboxVisual(cb, v);
                cb.updateHitbox();
                var lbl:FlxText = labelGroup.members[idx];
                if (lbl != null) {
                    lbl.x = cb.x + (cb.width * cb.scale.x) + labelOffsetX;
                    lbl.y = cb.y + (cb.height * cb.scale.y - lbl.size) / 2 + labelOffsetY;
                }
            }
        }
    }

public function updateArtworkForSong(songName:String):Void {
    // 1. Déterminer l'index cible basé sur le nom
    var nextIndex = switch(songName.toLowerCase()) {
        case "how to play": 1;
        case "metal reflection": 2;
        case "criminal targets": 3;
        case "crash out": 4;
        case "trick or treat": 5;
        case "trick or treat old": 6;
        case "periple": 7;
        case "starlight": 8;
        case "allocution": 9;
        case "gangstabattle": 10;
        case "new game": 11;            
        default: 0;
    };

    // 2. CONDITION CRUCIALE : Si l'index est identique et qu'une image est déjà chargée, 
    // on s'arrête là pour éviter de relancer l'animation de slide et le rechargement.
    if (nextIndex == curIndex && artImage.graphic != null) return;

    // 3. Sinon, on met à jour l'index et on affiche l'artwork normalement
    curIndex = nextIndex;

    var maxDiff:Int = artworks[curIndex].diffLabels.length - 1;
    if (currentDifficulty > maxDiff) currentDifficulty = maxDiff;

    showArtwork(curIndex);
}

    // Retourne le chemin de l'artwork selon la difficulté courante, avec fallback sur le chemin de base
    function getArtworkPath(index:Int):String {
        var a = artworks[index];
        var basePath = (a.path == "" || a.path == null) ? "artworks/placeholder" : a.path;
        if (a.difficultyArtworks != null && a.difficultyArtworks.exists(currentDifficultyName))
            return a.difficultyArtworks.get(currentDifficultyName);
        return basePath;
    }

    // Retourne le texte selon la difficulté courante, avec fallback sur le texte de base
    function getTextForDiff(index:Int):String {
        var a = artworks[index];
        if (a.difficultyTexts != null && a.difficultyTexts.exists(currentDifficultyName))
            return a.difficultyTexts.get(currentDifficultyName);
        return a.text;
    }

    // Retourne la description selon la difficulté courante, avec fallback sur la desc de base
    function getDescForDiff(index:Int):String {
        var a = artworks[index];
        if (a.difficultyDescs != null && a.difficultyDescs.exists(currentDifficultyName))
            return a.difficultyDescs.get(currentDifficultyName);
        return a.desc;
    }

    // Appele par FreeplayState apres chaque changeDiff() — source unique de verite
    public function setDifficulty(diff:Int):Void {
        // On mémorise les anciennes valeurs AVANT de changer la difficulté
        var oldPath = getArtworkPath(curIndex);
        var oldText = getTextForDiff(curIndex);
        var oldDesc = getDescForDiff(curIndex);

        // Maintenant seulement on met à jour le nom de difficulté
        if (diff >= 0 && diff < CoolUtil.difficulties.length)
            currentDifficultyName = StringTools.trim(CoolUtil.difficulties[diff].toLowerCase());

        var maxDiff:Int = artworks[curIndex].diffLabels.length - 1;
        currentDifficulty = Std.int(Math.max(0, Math.min(diff, maxDiff)));

        var newPath = getArtworkPath(curIndex);
        var newText = getTextForDiff(curIndex);
        var newDesc = getDescForDiff(curIndex);

        // Si l'artwork a changé, on déclenche le slide — sinon on met juste à jour la barre
        if (newPath != oldPath)
            showArtwork(curIndex);
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

    public function showArtwork(index:Int):Void {
        var a = artworks[index];
        var path = getArtworkPath(index); // Utilise l'artwork de la difficulté si disponible
        artImage.loadGraphic(Paths.image(path));
        artImage.scale.set(baseArtScale, baseArtScale);
        artImage.updateHitbox();
        artImage.screenCenter();
        artImage.x += 400;
        artImage.y += -40;
        startX = artImage.x;
        artImage.x = FlxG.width + artImage.width;
        targetX = startX;

        updateDifficultyBar();

        artDesc.text = getDescForDiff(index);
        artText.text = getTextForDiff(index);
        isAnimating = true;
    }

    public function updateDifficultyBar():Void {
        var a = artworks[curIndex];
        var rawValue:Float = 0;

        if (a != null) {
            // Priorite a la valeur nommee (diffs "bonus" type erect/corruption/etc.)
            if (a.difficultyValues != null && a.difficultyValues.exists(currentDifficultyName)) {
                rawValue = a.difficultyValues.get(currentDifficultyName);
            }
            // Sinon fallback sur l'array de base (Easy/Normal/Hard)
            else if (a.difficulties != null && a.difficulties.length > currentDifficulty) {
                rawValue = a.difficulties[currentDifficulty];
            }
        }

        barTargetPercent = Math.max(0, Math.min(rawValue / 20, 1));
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

    function isMouseInExpandedRect(cb:CheckboxThingie, mouseX:Float, mouseY:Float, margin:Float):Bool {
        var cam = FlxG.camera;
        var cbScreenX = cb.x - cam.scroll.x;
        var cbScreenY = cb.y - cam.scroll.y;
        var cbW = cb.width * cb.scale.x;
        var cbH = cb.height * cb.scale.y;
        return mouseX >= (cbScreenX - margin) && mouseX <= (cbScreenX + cbW + margin) &&
               mouseY >= (cbScreenY - margin) && mouseY <= (cbScreenY + cbH + margin);
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

            var hover:Bool = cb.overlapsPoint(mouseScreen);
            if (!hover) hover = isMouseInExpandedRect(cb, mx, my, clickMargin);

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
                    cb.daValue = newVal;
                    setCheckboxVisual(cb, newVal);
                    cb.updateHitbox();
                    var lbl2:FlxText = labelGroup.members[i];
                    if (lbl2 != null) {
                        lbl2.x = cb.x + (cb.width * cb.scale.x) + labelOffsetX;
                        lbl2.y = cb.y + (cb.height * cb.scale.y - lbl2.size) / 2 + labelOffsetY;
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
                            cb.daValue = newValP;
                            setCheckboxVisual(cb, newValP);
                            cb.updateHitbox();
                            var lblp:FlxText = labelGroup.members[i];
                            if (lblp != null) {
                                lblp.x = cb.x + (cb.width * cb.scale.x) + labelOffsetX;
                                lblp.y = cb.y + (cb.height * cb.scale.y - lblp.size) / 2 + labelOffsetY;
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
                            cb.daValue = newValB;
                            setCheckboxVisual(cb, newValB);
                            cb.updateHitbox();
                            var lblb:FlxText = labelGroup.members[i];
                            if (lblb != null) {
                                lblb.x = cb.x + (cb.width * cb.scale.x) + labelOffsetX;
                                lblb.y = cb.y + (cb.height * cb.scale.y - lblb.size) / 2 + labelOffsetY;
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
                var hoverK:Bool = cbk.overlapsPoint(mouseScreen);
                if (!hoverK) hoverK = isMouseInExpandedRect(cbk, mx, my, clickMargin);
                var lblK:FlxText = labelGroup.members[i];
                if (lblK != null) hoverK = hoverK || lblK.overlapsPoint(mouseScreen);
                if (hoverK) {
                    var optK = optionsArray[i];
                    if (optK != null) {
                        var newValK = !(optK.getValue() == true);
                        optK.setValue(newValK);
                        optK.change();
                        cbk.daValue = newValK;
                        setCheckboxVisual(cbk, newValK);
                        cbk.updateHitbox();
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
