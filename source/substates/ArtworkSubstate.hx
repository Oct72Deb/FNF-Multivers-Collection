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

class ArtworkSubstate extends FlxSubState {

    // press-tracking pour éviter d'avoir à rester appuyé
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
    var artName:FlxText;
    var artDesc:FlxText;

    // Options infra (USING local ArtworkGameplayOption to avoid duplicate type names)
    private var optionsArray:Array<ArtworkGameplayOption> = [];
    private var curIndex:Int = 0;
    public var currentWeek:String;

    // ---------- BOX CONFIG ----------
    var scaleBox:Float = 0.4;    // downscale des cases (laisse comme avant)
    var clickMargin:Float = 8;  // tolérance autour de la case
    var labelOffsetX:Float = 32; // <-- déplacer le texte PLUS à droite (avant : 8)
    var labelOffsetY:Float = 0;
    var gapY:Float = 100;         // <-- espace vertical entre les cases (avant : 56)
    // ----------------------------


    public function new(week:String) {
        super();
        currentWeek = week;
        persistentUpdate = true;
        persistentDraw = true;
    }

    var artworks:Array<{name:String, path:String, desc:String}> = [
        { name: "Poster Placeholder", path: "artworks/placeholder", desc: "Un pur test comme les autres." },
        { name: "Pixel Brothers", path: "artworks/HOW_TO_PLAY", desc: "Apprenez a raper contre les frères Mario et Luigi !" },
        { name: "Poster Mario", path: "artworks/new_game", desc: "Un classique du jeux rétro !" },
        { name: "Funky Gangsta", path: "artworks/SilvaGunner_Banner", desc: "Tu fous quoi ici ??" }
    ];

    override function create() {
        super.create();

        // panel background
        bg = new FlxSprite(Std.int(FlxG.width * 0.65), 0)
            .makeGraphic(Std.int(FlxG.width * 0.35), FlxG.height, FlxColor.fromRGB(0, 0, 0, 0));
        add(bg);

        // artwork image + texts
        artImage = new FlxSprite(bg.x + 60, 180);
        add(artImage);

        artName = new FlxText(bg.x + 25, 150, bg.width - 80, "", 24);
        artName.setFormat(null, 24, FlxColor.WHITE, "center");
        add(artName);

        artDesc = new FlxText(bg.x + 25, 540, bg.width - 80, "", 16);
        artDesc.setFormat(null, 16, FlxColor.GRAY, "center");
        add(artDesc);

        // groups
        checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
        add(checkboxGroup);

        labelGroup = new FlxTypedGroup<FlxText>();
        add(labelGroup);

        // prepare options
        getOptions();

        // create checkboxes from options
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

        // sync visuals from prefs
        reloadCheckboxes();

        // apply initial opts (ensures keys exist & saves)
        applyOptions();

        updateArtworkForSong(PlayState.SONG.song);
    }

    // create the list of options we want inside ArtworkSubstate
    function getOptions():Void {
        optionsArray = [];
        optionsArray.push(new ArtworkGameplayOption("Practice Mode", "practice", "bool", false));
        optionsArray.push(new ArtworkGameplayOption("Botplay", "botplay", "bool", false));
        // add more options here if needed
    }

    // animation helper
    function setCheckboxVisual(cb:CheckboxThingie, value:Bool):Void {
        cb.animation.play(value ? "on" : "off");
        cb.animation.play(value ? "checked" : "unchecked");
    }

    // sync checkboxes from prefs
    function reloadCheckboxes():Void {
        for (cb in checkboxGroup) {
            var idx = cb.ID;
            if (idx >= 0 && idx < optionsArray.length) {
                var v = optionsArray[idx].getValue() == true;
                cb.daValue = v;
                setCheckboxVisual(cb, v);
                cb.updateHitbox();
                try {
                    var lbl:FlxText = labelGroup.members[idx];
                    if (lbl != null) {
                        lbl.x = cb.x + (cb.width * cb.scale.x) + 8;
                        lbl.y = cb.y + (cb.height * cb.scale.y - lbl.size) / 2;
                    }
                } catch(e:Dynamic) {}
            }
        }
    }

    public function updateArtworkForSong(songName:String):Void {
        curIndex = switch(songName.toLowerCase()) {
            case "how to play": 1;
            case "new game": 2;
            case "gangstabattle": 3;
            default: 0;
        };
        showArtwork(curIndex);
    }

    var isAnimating:Bool = false;
    var startX:Float = 0;

    // Taille des artwork général
    public function showArtwork(index:Int):Void {
        var a = artworks[index];
        var path = (a.path == "" || a.path == null) ? "artworks/placeholder" : a.path;
        artImage.loadGraphic(Paths.image(path));
        artImage.scale.set(0.33, 0.33);
        artImage.updateHitbox();
        artImage.screenCenter();
        artImage.x += 400;
        startX = artImage.x;
        artImage.x = FlxG.width + artImage.width;
        targetX = startX;
        artName.text = a.name;
        artDesc.text = a.desc;
        isAnimating = true;
    }

    public function applyOptions():Void {
        for (opt in optionsArray) {
            if (opt != null) {
                ClientPrefs.gameplaySettings.set(opt.variable, opt.getValue());
            }
        }
        ClientPrefs.saveSettings();

        if (PlayState.instance != null) {
            try {
                PlayState.instance.cpuControlled = ClientPrefs.gameplaySettings.get("botplay");
            } catch(e:Dynamic) {}
            try {
                PlayState.instance.practiceMode = ClientPrefs.gameplaySettings.get("practice");
            } catch(e:Dynamic) {}
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

    if (isAnimating) {
        artImage.x = FlxMath.lerp(artImage.x, targetX, 0.15);
        if (Math.abs(artImage.x - targetX) < 1) {
            artImage.x = targetX;
            isAnimating = false;
        }
    }

    // refresh hitboxes
    for (cb in checkboxGroup) cb.updateHitbox();

    var mouseScreen = FlxG.mouse.getScreenPosition();
    var mx = mouseScreen.x, my = mouseScreen.y;

    // lecture des états souris
    var justP = FlxG.mouse.justPressed;
    var justR = FlxG.mouse.justReleased;
    var pressed = FlxG.mouse.pressed; // true while held (utile en fallback)

    var clickedThisFrame:Bool = justP || justR;

    // parcourir les cases
    var changed:Bool = false;
    for (i in 0...checkboxGroup.members.length) {
        var cb:CheckboxThingie = checkboxGroup.members[i];
        if (cb == null) continue;

        // recalcul hover : overlapsPoint OR expanded rect OR label clicked
        var hover:Bool = false;
        try { hover = cb.overlapsPoint(mouseScreen); } catch(e:Dynamic) { hover = false; }
        if (!hover) hover = isMouseInExpandedRect(cb, mx, my, clickMargin);

        // label
        try {
            var lbl:FlxText = labelGroup.members[i];
            if (lbl != null) hover = hover || lbl.overlapsPoint(mouseScreen);
        } catch(e:Dynamic) {}

        // press start detection: si on vient d'appuyer et la souris est sur la case -> on marque le press-start
        if (justP && hover) {
            // marque press-start pour l'option correspondante
            if (checkboxPractice == cb) _pressingPractice = true;
            if (checkboxBot == cb) _pressingBot = true;

            // réponse immédiate si tu veux : toggle direct sur justPressed (snappy)
            var optImmediate = optionsArray[i];
            if (optImmediate != null) {
                var newVal = !(optImmediate.getValue() == true);
                optImmediate.setValue(newVal);
                optImmediate.change();
                cb.daValue = newVal;
                setCheckboxVisual(cb, newVal);
                cb.updateHitbox();
                // reposition label
                try {
                    var lbl2:FlxText = labelGroup.members[i];
                    if (lbl2 != null) {
                        lbl2.x = cb.x + (cb.width * cb.scale.x) + 8;
                        lbl2.y = cb.y + (cb.height * cb.scale.y - lbl2.size) / 2;
                    }
                } catch(e:Dynamic) {}
                changed = true;
                // on a déjà consommé la pression immédiate : reset press-start pour éviter double-toggle au release
                if (checkboxPractice == cb) _pressingPractice = false;
                if (checkboxBot == cb) _pressingBot = false;
            }
        }

        // release handling: si on relâche et que l'appui avait commencé sur cette case, toggle (fallback)
        if (justR) {
            // pratique
            if (checkboxPractice == cb && _pressingPractice) {
                // si la case n'a pas déjà été togglée par le immediate (newVal), on toggle maintenant
                var optP = optionsArray[i];
                if (optP != null) {
                    var curP = optP.getValue() == true;
                    // si curP correspond à cb.daValue (i.e. pas togglé par immediate) -> on toggle
                    if (cb.daValue == curP) {
                        var newValP = !curP;
                        optP.setValue(newValP);
                        optP.change();
                        cb.daValue = newValP;
                        setCheckboxVisual(cb, newValP);
                        cb.updateHitbox();
                        try {
                            var lblp:FlxText = labelGroup.members[i];
                            if (lblp != null) {
                                lblp.x = cb.x + (cb.width * cb.scale.x) + 8;
                                lblp.y = cb.y + (cb.height * cb.scale.y - lblp.size) / 2;
                            }
                        } catch(e:Dynamic) {}
                        changed = true;
                    }
                }
                _pressingPractice = false;
            }

            // bot
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
                        try {
                            var lblb:FlxText = labelGroup.members[i];
                            if (lblb != null) {
                                lblb.x = cb.x + (cb.width * cb.scale.x) + 8;
                                lblb.y = cb.y + (cb.height * cb.scale.y - lblb.size) / 2;
                            }
                        } catch(e:Dynamic) {}
                        changed = true;
                    }
                }
                _pressingBot = false;
            }
        }

        // fallback : si la souris est maintenue (pressed) mais une frame justPressed a été manquée
        // on ignore pour éviter toggle continu, mais on pourrait implémenter autre comportement si nécessaire.
    }

    // repositionne les labels pour suivre la checkbox (utile si scale/pos changent)
    for (i in 0...checkboxGroup.members.length) {
        var cbk = checkboxGroup.members[i];
        var lbk = labelGroup.members[i];
        if (cbk != null && lbk != null) {
            lbk.x = cbk.x + (cbk.width * cbk.scale.x) + labelOffsetX;
            lbk.y = cbk.y + (cbk.height * cbk.scale.y - lbk.size) / 2 + labelOffsetY;
        }
    }

    // touche clavier fallback (Z / SPACE / ENTER) — toggle si on survole une case
    if (!changed && (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER)) {
        for (i in 0...checkboxGroup.members.length) {
            var cbk:CheckboxThingie = checkboxGroup.members[i];
            if (cbk == null) continue;
            var hoverK:Bool = false;
            try { hoverK = cbk.overlapsPoint(mouseScreen); } catch(e:Dynamic) { hoverK = false; }
            if (!hoverK) hoverK = isMouseInExpandedRect(cbk, mx, my, clickMargin);
            try {
                var lblK:FlxText = labelGroup.members[i];
                if (lblK != null) hoverK = hoverK || lblK.overlapsPoint(mouseScreen);
            } catch(e:Dynamic) {}
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
        // refresher pour la sécurité
        reloadCheckboxes();
    }
    }
}

/* --------------------------
   Artwork-local GameplayOption
   (renamed to avoid colliding with global GameplayOption)
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

        // ensure key exists in prefs
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