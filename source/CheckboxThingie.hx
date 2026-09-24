package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class CheckboxThingie extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	// Multiplicateur de taille appliqué à la construction (1 = taille d'origine, 0.6 = 60%, etc.)
	// NE JAMAIS rescaler une CheckboxThingie après coup (cb.scale.set / cb.updateHitbox) :
	// les offsets faits-main ci-dessous sont en pixels absolus à l'écran, pas relatifs à
	// l'échelle du sprite. Il faut donc rétrécir ICI, une seule fois, à la construction,
	// pour que les offsets soient recalculés à la même échelle en même temps que la taille.
	var sizeMult:Float = 1;

	public function new(x:Float = 0, y:Float = 0, ?checked = false, ?sizeMult:Float = 1) {
		super(x, y);

		this.sizeMult = sizeMult;

		frames = Paths.getSparrowAtlas('checkboxanim');
		animation.addByPrefix("unchecked", "checkbox0", 24, false);
		animation.addByPrefix("unchecking", "checkbox anim reverse", 24, false);
		animation.addByPrefix("checking", "checkbox anim0", 24, false);
		animation.addByPrefix("checked", "checkbox finish", 24, false);

		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(0.9 * sizeMult * width));
		updateHitbox();

		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		daValue = checked;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y + 30 + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}
		super.update(elapsed);
	}

	private function set_daValue(check:Bool):Bool {
		if(check) {
			if(animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking') {
				animation.play('checking', true);
				offset.set(34 * sizeMult, 25 * sizeMult);
			}
		} else if(animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking') {
			animation.play("unchecking", true);
			offset.set(25 * sizeMult, 28 * sizeMult);
		}
		return check;
	}

	private function animationFinished(name:String)
	{
		switch(name)
		{
			case 'checking':
				animation.play('checked', true);
				offset.set(3 * sizeMult, 12 * sizeMult);

			case 'unchecking':
				animation.play('unchecked', true);
				offset.set(0 * sizeMult, 2 * sizeMult);
		}
	}
}