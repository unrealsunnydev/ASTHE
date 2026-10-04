/*
	Sunnydev31 - 2026-06-04
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.objects;

import asthe.states.PlayState;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirectionFlags;

class Character extends AstheSprite {
	public static var instance:Character = null;

	var controls:Null<Controls> = Controls.instance; // Lol

	// Current Player
	public var current:String = Constants.DEFAULT_CHARACTER;

	public var json:asthe.data.CharacterData;
	private static var exAnim:Dynamic = {}; // Data store for new animations

	private static var sheets:Map<String, FlxAtlasFrames> = new Map();

	// Game
	public var score:Int = 0; // NOT IMPLEMENTED
	public var rings:Int = 0; // NOT IMPLEMENTED
	public var lives:Int = 3; // NOT IMPLEMENTED
	public var continues:Int = 0; // NOT IMPLEMENTED
	public final lifeIcon:String = Constants.LIFE_ICON;

	// Statistics
	/**
		Gets the character current state
	**/
	public var state:StateList;
	public var isSuper:Bool = false;
	public var JUMP_SPEED:Int      = -450;
	public var GRAVITY:Int         =  980;
	public var ACCELERATION:Int    =  600;
	public var DESACCELERATION:Int =  400; // Drag value
	public var MAX_SPEED:Int       =  300;

	public function new(x:Float, y:Float, ?char:String) {
		super(x, y);
		if (char.isBlank()) char = Constants.DEFAULT_CHARACTER;

		instance = this;
		changeChar(char);

		acceleration.y = GRAVITY;
		maxVelocity.x = MAX_SPEED;

		origin.set(width / 2, height);
		updateHitbox();
	}

	override function update(e:Float) {
		updateAnimations(e);

		super.update(e);
	}

	public function changeChar(char:String) {
		current = char;

		log('Changed character to ($char/$current)');

		if (Paths.fileExists('data/characters/$char.json', TEXT)) {
			json = cast Paths.parseJson('data/characters/$char.json');
		}
		else {
			json = cast Paths.parseJson('data/characters/${Constants.DEFAULT_CHARACTER}.json');
			log('Character not found, using default (${Constants.DEFAULT_CHARACTER})'.warn());
		}

		if (Reflect.hasField(json, "extraAnimations"))
			for (extra in json.extraAnimations){
				if (extra != null && !(extra.name).isBlank())
					addAnim(extra.name);
			}

		loadAnimations();
		var palette:Array<String> = json.palettes?.normal;
		if (ArrayUtil.isBlank(palette) || palette.length < 4) {
			palette = ["#FF0000", "#FF5000", "#00FF00", "#0000FF"];
		}
		this.applyPalette([
			FlxColor.fromString(palette[0]),
			FlxColor.fromString(palette[1]),
			FlxColor.fromString(palette[2]),
			FlxColor.fromString(palette[3])
		]);

		state = IDLE;
	}

	function loadAnimations():Void {
		frames = Paths.getSparrowAtlas('characters/$current/main');

		var anims = json.animations;
		if (!ArrayUtil.isBlank(anims)) {
			for (anim in anims) {
				var animName   = ((anim.name).trim() ?? ""),
					animPrefix = ((anim.prefix).trim() ?? animName),
					animFPS    = anim.fps ?? 30,
					animLoop   = anim.loop ?? false;

				if (animName.endsWith("-loop")) {
					animLoop = true;
				}

				if (!ArrayUtil.isBlank(anim.indices))
					animation.addByIndices(animName, animPrefix, anim.indices, "", animFPS, animLoop);
				else
					animation.addByPrefix(animName, animPrefix, animFPS, animLoop);
			}
		}
	}

	public function playAnim(name:asthe.data.CharacterAnimation.AnimList, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		animation.play(name, force, reversed, frame);
	}

	/**
		Adds an animation to the list
		@param name Name of this animation (Prefered style: `ANI_ANIMATION`, e.g. `ANI_ROLLING`)
		@type Void
	**/
	public function addAnim(name:String):Void {
		Reflect.setField(exAnim, name, name);
		log('Added animation to the list. ($name)');
	}

	/**
		Checks if an animation exists.
		@param name Name of the animation
		@return Bool
	**/
	public function animExists(name:String):Bool {
		if (Reflect.hasField(exAnim, name) || !name.isBlank()) {
			var nameN:String = Std.string(Reflect.field(exAnim, name) ?? name);
			return ((!nameN.isBlank()) && animation.getByName(nameN) != null);
		}

		log("Animation ".warn() + name + " doesn't exists in the list!");
		return false;
	}

	var deadBySpikes:Bool = false; // When player dies by spikes, the death sound is different. Maybe plays together with the normal sound?
	override public function kill() {
		velocity.x = 0;
		velocity.y = -0x68000;
		playAnim("ANI_DYING");

		AstheSound.playSound("Hurt");
	}

	/**
		Updates the movement for Playable characters
	**/
	public function updateMoves() {
		if (controls.LEFT_P || controls.RIGHT_P) {
			acceleration.x = (controls.LEFT_P) ? -ACCELERATION : ACCELERATION;
			state = WALKING;
		}
		else {
			acceleration.x = 0;
			state = IDLE;
		}

		// In PlayState, make action buttons act like jump buttons
		if (controls.JUMP || controls.BACK) {
			jump();
		}
	}

	/**
		Updates the animations for this character
		@param e Elapsed FlxState time
	**/
	function updateAnimations(e:Float):Void {

		if (controls.DOWN_P && state != ROLLING) {
			playAnim("ANI_LOOK_DOWN");
			return;
		}

		switch (state) {
			case IDLE:
				playAnim("ANI_STOPPED");
				return;
			case WALKING:
				playAnim("ANI_WALKING");
				return;
			case ROLLING:
				playAnim("ANI_ROLLING");
				return;
			case JUMPING:
				playAnim("ANI_JUMPING");
				return;
			case DYING:
				playAnim("ANI_DYING");
				return;
			case _: return;
		}
	}

	/**
		Makes the character to jump!
	**/
	public function jump():Void {
		if (isTouching(FlxDirectionFlags.FLOOR)) {
			state = JUMPING;
			AstheSound.playSound(ConstantSound.PLAYER_JUMP);
			velocity.y = this.JUMP_SPEED;
		}
	}

	/**
		Makes the character to roll
	**/
	public function roll():Void {
		AstheSound.playSound(ConstantSound.PLAYER_ROLL);
		state = ROLLING;
	}

	/**
		List of requirements to achieve a transformation, like Super Sonic
		@default `rings >= 50`
		@return Bool
	**/
	public function canTransform():Bool {
		if (rings < 50) return false;

		return true;
	}

	// TODO: Add Chaos Emeralds collection and validate them before transforming
	/**
		Event to make a character achieve a transformation, just like Super Sonic
		@returns Void
		@throws HaxeException If the character doesn't have a super form, or it already achieved the super transformation
	**/
	public function transform(e:Float):Void {
		if (!json.hasSuper) {
			log("The character " + (json?.name ?? current) + " doesn't have a super form!");
			isSuper = false;
			return;
		}

		if (!canTransform()) {
			log("Character '" + (json?.name ?? current) + "' doesn't achieved the transformation requirements!");
			isSuper = false;
			return;
		}

		if (isSuper) {
			log("The character " + (json?.name ?? current) + " is already transformed!");
			return;
		}

		isSuper = true;
		state = TRANSFORM;
		AstheSound.playSound(ConstantSound.PLAYER_TRANSFORM);

		if (rings > 0 && (Math.floor(e * 3000) % 2 == 0)) {
			rings--;
		}

		// Palette animation - Super glow into white and loop that back
		/*
		var palette:Array<String> = json.palettes.super ?? json.palettes.normal;

		if (!ArrayUtil.isBlank(palette) && palette.length >= 4) {
			PlayState.instance?.hud?.livesIcon?.setSuper(true);
			PlayState.instance?.hud?.livesIcon?.applyPalette([
				for (i in 0...3)
					FlxTween.color(null, 1, (palette[i] != null) ? FlxColor.fromString(palette[i]) : Constants.PALETTE_OVERRIDE[i], FlxColor.WHITE, { type: PINGPONG })
			]);
			this.applyPalette([
				for (i in 0...3)
					FlxTween.color(null, 1, (palette[i] != null) ? FlxColor.fromString(palette[i]) : Constants.PALETTE_OVERRIDE[i], FlxColor.WHITE, { type: PINGPONG })
			]);
		} */
	}

	/**
		Event to make a character revert a untransformation, like Super -> Normal state
		@returns Void
		@throws HaxeException If the character doesn't have a super form, or it already has untransformation
	**/
	public function untransform():Void {
		if (json.hasSuper && isSuper) {
			isSuper = false;
			PlayState.instance?.hud?.livesIcon?.setSuper(false);

			// TODO: Use FlxColor.interpolate to create a color tween between Super Palette and White
			/*
			var palette:Array<String> = json.palettes.normal;
			if (palette != null && palette.length >= 4) {
				this.applyPalette([
					FlxColor.fromString(palette[0]),
					FlxColor.fromString(palette[1]),
					FlxColor.fromString(palette[2]),
					FlxColor.fromString(palette[3])
				]);
			}
			*/
		}
		else {
			log("The character " + (json?.name ?? current) + " doesn't have a super form, or it already have detransformed!");
			return;
		}
	}

	static function log(msg:String, ?args:haxe.PosInfos) {
		trace(msg.infoCustom("CHARACTER", AnsiList.BG_BRIGHT_GREEN), args);
	}
}

/**
	Current character state list
**/
enum StateList {

	/**
		The character has stopped / In idle state
	**/
	IDLE;

	/**
		The character is walking
	**/
	WALKING;

	/**
		The character is running
	**/
	RUNNING;

	/**
		The character is jumping
	**/
	JUMPING;

	/**
		The character is rolling
	**/
	ROLLING;

	/**
		The character is transforming
	**/
	TRANSFORM;

	/**
		The character achieve the dying state
	**/
	DYING;
}