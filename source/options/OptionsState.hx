package options;

#if desktop
import Discord.DiscordClient;
#end

import options.OptionsState;
import states.MusicBeatState;
import states.LoadingState;
import states.MainMenuState;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;
class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var menuItemsHidden:Bool = false; // true tant qu'un sous-menu d'options est ouvert par-dessus

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		// Garde cet état actif pendant qu'un sous-menu est ouvert par-dessus : les particules continuent de bouger
		persistentUpdate = true;

		// Même fond que celui affiché derrière le personnage dans le menu principal (mis en cache par MainMenuState)
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(MainMenuState.lastBgGraphicPath));
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

// Ajoute automatiquement les particules (cœurs et/ou cristaux) selon le personnage en cache
		MainMenuState.addMenuParticles(this);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	// true uniquement si le sous-état ouvert est l'un des sous-menus d'options (et PAS, par exemple,
	// le fondu CustomFadeTransition d'entrée/sortie, qui est aussi un sous-état de cet état).
	function isOptionsSubStateOpen():Bool {
		return subState != null && (Std.downcast(subState, BaseOptionsMenu) != null
			|| Std.downcast(subState, ControlsSubState) != null
			|| Std.downcast(subState, NotesSubState) != null);
	}

	// Les sous-menus ont un fond transparent : on cache la liste des options (mais pas le fond ni les
	// particules) tant que l'un d'eux est ouvert. Fait dans draw() pour rester synchrone avec
	// l'ouverture/fermeture réelle du sous-menu.
	override function draw() {
		var hide:Bool = isOptionsSubStateOpen();
		if (menuItemsHidden != hide) {
			menuItemsHidden = hide;
			grpOptions.visible = !hide;
			selectorLeft.visible = !hide;
			selectorRight.visible = !hide;
		}
		super.draw();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		// Un sous-menu est ouvert : ses propres touches ne doivent pas déclencher celles d'ici
		if (subState != null) return;

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}