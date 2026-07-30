package states;

import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

class ErrorState extends FlxSubState
{
	public var errorMsg:String;

	public function new(error:String)
	{
		super();
		this.errorMsg = error;
	}

	override function create()
	{
		super.create();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.8;
		add(bg);

		var errorText = new FlxText(0, 0, FlxG.width - 200, errorMsg, 32);
		errorText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE , CENTER);
		errorText.scrollFactor.set();
		errorText.screenCenter();
		add(errorText);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
			close();

		super.update(elapsed);
	}
}