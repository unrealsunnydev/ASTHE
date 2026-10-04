/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-04-14
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.game;

import asthe.states.PlayState;
import asthe.objects.LifeIcon;

import flixel.FlxSprite;
import flixel.util.FlxStringUtil;

/**
	Dedicated class to handle the HUD, making PlayState more cleaner and easier to manage.

	Also, this allows us to easily add more HUD elements and using functions
	for scripts, without leaving it all in PlayState, yay!
	@author Sunnydev31 (unreal.sunnydev)
**/
class HudGame extends FlxSpriteGroup {

	// { region Variables
	public static var instance:Null<HudGame> = null;

	/**
		"Layering" value for the HUD, used to make the HUD elements go over/under the rest of other elements
		in game.

		--- DEFAULT OPTIONS ---
		"Score, Time, Rings" text: Z_INDEX + 1
		"Score, Time, Rings" text values: Z_INDEX + 2
		"X, Y" player position text: Z_INDEX + 1
		"X, Y" player position text values: Z_INDEX + 2
		Live icons and text value: Z_INDEX + 3

		@default `0xE000`
	**/
	public static final Z_INDEX:Int = 0xE000;

	/**
		Stores the player score, actually this follows the Sonic 3 & Knuckles system
		Where the score is multiplied by 10.
	**/
	public var score(default, set):Int = 0;

	/** Stores the current stage time, actually this is unused. **/
	public var time(default, set):Float = 0.0;

	/** Stores the P1 rings, actually this is unused... Or not?... **/
	public var rings(default, set):Int = 0;

	/** Stores the player lives, and you know the rest of this description. **/
	public var lives(default, set):Int = 3;


	// --- DRAWABLE HUD ELEMENTS --- //

	/** "SCORE" text element. **/
	public var scoreTxt:AstheBitmapText;

	/** "TIME" text element. **/
	public var timeTxt:AstheBitmapText;

	/** "RINGS" text element. **/
	public var ringsTxt:AstheBitmapText;

	/**
		Readable lives counter.
		This follows the style based on 8-bit games.
	**/
	public var livesTxt:AstheBitmapText;

	// --- READABLE HUD VALUES --- //

	/*  These are only used to show the values on the screen
		They don't need a description, do they?...          */

	public var scoreValTxt:AstheBitmapText;
	public var timeValTxt:AstheBitmapText;
	public var ringsValTxt:AstheBitmapText;

	// --- DEBUG ONLY --- //

	/** Debug sprite to show the player X position. **/
	public var posX:AstheSprite;

	/** Debug sprite to show the player Y position. **/
	public var posY:AstheSprite;

	public var posXTxt:Null<AstheBitmapText>;
	public var posYTxt:Null<AstheBitmapText>;

	/** Instance used to show the player life icon. **/
	public var livesIcon:Null<LifeIcon>;
	// } end region

	/**
		Cronstructor for the HUD, remember to use a instance variable!
		@param x HUD Horizontal position, DEBUG sprites doesn't follow this.
		@param y HUD Vertical position, Life sprites doesn't follow this.
		@author Sunnydev31 (unreal.sunnydev)
	**/
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		instance = this;

		// Init variables
		scoreTxt    = AstheBitmapText.createAngelCode(0, 0, Locale.getString("hud_text_score"), "HUD");
		scoreValTxt = AstheBitmapText.createAngelCode(0, 0, Std.string(score), "HUD");
		timeTxt     = AstheBitmapText.createAngelCode(0, 0, Locale.getString("hud_text_time"), "HUD");
		timeValTxt  = AstheBitmapText.createAngelCode(0, 0, StringUtil.formatTime(time, ClientPrefs.data.options.showMiliseconds), "HUD");
		ringsTxt    = AstheBitmapText.createAngelCode(0, 0, Locale.getString("hud_text_rings"), "HUD");
		ringsValTxt = AstheBitmapText.createAngelCode(0, 0, Std.string(rings), "HUD");
		if (PlayState.instance != null) {
			var player:Null<String> = PlayState.instance?.player?.current ?? Constants.DEFAULT_CHARACTER;
			livesIcon = new LifeIcon(player);
			livesTxt  = AstheBitmapText.createAngelCode(0, 0, Std.string(lives), "HUD");
		}

		createScoreHud(x, y);
		createTimeHud (x, y + 16);
		createRingsHud(x, y + 32);
		if (PlayState.instance != null) {
			#if mobile
			createLivesHud(FlxG.width - 64, y);
			#else
			createLivesHud(x, Std.int(FlxG.height * 0.9));
			#end
		}
		createDebugHud(FlxG.width - 60, y #if mobile + 18 #end);
	}

	/**
		Creates the score HUD element (Score counter and text)
		@param x Horizontal position on screen, default is 0
		@param y Vertical position on screen, default is 0
		@author Sunnydev31 (unreal.sunnydev)
	**/
	public dynamic function createScoreHud(?x:Float = 0, ?y:Float = 0):Void {
		scoreTxt.setPosition(x, y);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		scoreValTxt.setPosition(x + scoreTxt.width + 37, y);
		scoreValTxt.scrollFactor.set();
		scoreValTxt.fieldWidth = 100;
		scoreValTxt.alignment = AstheText.TextAlign.RIGHT;
		scoreValTxt.multiLine = false;
		add(scoreValTxt);
	}

	/**
		Creates the time HUD element (Time counter and text)
		@param x Horizontal position on screen, default is 0
		@param y Vertical position on screen, default is 0
		@author Sunnydev31 (unreal.sunnydev)
	**/
	public dynamic function createTimeHud(?x:Float = 0, ?y:Float = 0) {
		timeTxt.setPosition(x, y);
		timeTxt.scrollFactor.set();
		add(timeTxt);

		timeValTxt.setPosition(x + timeTxt.width + 37, y);
		timeValTxt.scrollFactor.set();
		timeValTxt.fieldWidth = 100;
		timeValTxt.alignment = AstheText.TextAlign.RIGHT;
		timeValTxt.multiLine = false;
		add(timeValTxt);
	}

	/**
		Creates the rings HUD element (Ring counter and text)
		@param x Horizontal position on screen, default is 0
		@param y Vertical position on screen, default is 0
		@author Sunnydev31 (unreal.sunnydev)
	**/
	public dynamic function createRingsHud(?x:Float = 0, ?y:Float = 0) {
		ringsTxt.setPosition(x, y);
		ringsTxt.scrollFactor.set();
		add(ringsTxt);

		ringsValTxt.setPosition(x + ringsTxt.width + 37, y);
		ringsValTxt.fieldWidth = 80;
		ringsValTxt.alignment = AstheText.TextAlign.RIGHT;
		ringsValTxt.multiLine = false;
		ringsValTxt.scrollFactor.set();
		add(ringsValTxt);
	}

	/**
		Creates the lives HUD element (Live counter and icon)

		@param x Horizontal position on screen, default is 0
		@param y Vertical position on screen, default is 0
		@author Sunnydev31 (unreal.sunnydev)
	**/
	public dynamic function createLivesHud(?x:Float = 0, ?y:Float = 0) {
		livesIcon.setPosition(x, y);
		add(livesIcon);

		livesTxt.setPosition(x + (livesIcon.frameWidth + 1), y);
		livesTxt.scrollFactor.set();
		add(livesTxt);
	}

	public dynamic function createDebugHud(?x:Float = 0, ?y:Float = 0) {
		#if debug
		posX = AstheSprite.create(x, y, "HUD/posX");
		posX.color = FlxColor.YELLOW;
		add(posX);

		posXTxt = AstheBitmapText.createAngelCode(x + posX.width + 1, y, '?', "HUD");
		add(posXTxt);

		posY = AstheSprite.create(x, y + 13, "HUD/posY");
		posY.color = FlxColor.YELLOW;
		add(posY);

		posYTxt = AstheBitmapText.createAngelCode(x + posY.width + 1, y + 13, '?', "HUD");
		add(posYTxt);
		#end
	}

	override function update(e:Float) {
		super.update(e);

		#if debug
		posXTxt.text = StringTools.hex(Std.int(PlayState.instance.player.x), 6);
		posYTxt.text = StringTools.hex(Std.int(PlayState.instance.player.y), 6);

		posX.color = (PlayState.instance.player.x >= 0xFFFF) ? 0xFFFF0000 :  0xFFFFFF00;
		posY.color = (PlayState.instance.player.y >= 0xFFFF) ? 0xFFFF0000 :  0xFFFFFF00;
		#end
	}

	// --- HUD EVENT UPDATERS --- //
	// Using event setters seems to be more efficient than using onUpdate event.

	private function set_score(v:Int):Int {
		scoreValTxt.text = Std.string(score * Constants.HUD_SCORE_MULTIPLIER);
		score = v;

		return score;
	}

	private function set_time(v:Float):Float {
		timeValTxt.text = StringUtil.formatTime(v, ClientPrefs.data.options.showMiliseconds);
		timeTxt.color = (v >= 540) ? FlxColor.RED : FlxColor.WHITE; // 9 Minutes, display the time text in red

		time = v;
		return time;
	}

	private function set_rings(v:Int):Int {
		v = MathUtil.clamp(v, 0, Constants.HUD_RINGS_MAX);
		ringsValTxt.text = Std.string(v);
		rings = v;

		return rings;
	}

	private function set_lives(v:Int):Int {
		v = MathUtil.clamp(v, 0, Constants.HUD_LIVES_MAX);
		livesTxt.text = Std.string(v);
		lives = v;

		return lives;
	}
}