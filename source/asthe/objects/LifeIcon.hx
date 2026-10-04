/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-06-04
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.objects;

import flixel.math.FlxPoint;

class LifeIcon extends AstheSprite {

	public var character:String = null;
	public var offsets:FlxPoint = FlxPoint.get(0, 0);

	public function new(char:String) {
		super();
		//trace("char is {0}", char);

		init(char);
		updatePalette([]);
		scrollFactor.set();
	}

	/**
		Initializes the life icon from character data.

		@param char Character identifier
		@throws HaxeException If character JSON is missing or icon file not found
	**/
	public function init(char:String):Void {
		if (character == char) return;

		character = char;

		loadAdaptiveSpriteSheet('liveIcons/$char');
		loadAnimations();
	}

	// Leaving it public for scripts to override it
	/**
		Loads the animations for the Life Icon

		Remember to call `animation.play`!
	**/
	public function loadAnimations():Void {
		animation.add("normal", [0], 0, false, false);
		animation.add("super",  [1], 0, false, false);
		animation.play("normal");
	}

	/**
		Set the LifeIcon animations to Super state (Frame 1)
		@param isSuper Condition (True or False)
	**/
	public function setSuper(isSuper:Bool):Void {
		animation.play(isSuper ? "super" : "normal");
		updatePalette([]);
	}

	override public function updateHitbox():Void {
		super.updateHitbox();
		if (offsets != null) {
			offset += offsets;
		}
	}
}