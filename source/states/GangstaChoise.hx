package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class WarningDevStates extends FlxState
{
	var warnText:FlxText;

	override public function create()
	{
		super.create();

		// Fond noir en backup
		var backupBg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(backupBg);

		// Arrière-plan image
		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image("menuBG")); // change selon le chemin réel
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.25; // Ajuste l'opacité si nécessaire
		add(bg);
		
		// Texte simple, police par défaut
		warnText = new FlxText(0, FlxG.height / 3, FlxG.width,
            "Choose your Difficulty",
			24);
		warnText.setFormat(null, 24, FlxColor.WHITE, "center");
		add(warnText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});

			// Passe à l'état TitleState quand ENTER est pressé
			FlxG.switchState(new TitleState());
		}
	}
}