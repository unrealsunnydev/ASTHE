/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-08-27
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.backend;

import asthe.backend.macro.GitTools;

class Constants {

	// Git
	/**
		Gets the current Git commit hash
	**/
	@:keep public static final GIT_COMMIT_HASH:String = GitTools.getCommitHash();

	/**
		Returns the repository URL of the project
	**/
	public static final GIT_REPO_URL:String = "https://github.com/unrealsunnydev/ASTHE";

	// Fonts
	inline public static final ABSOLUTE_FONT_GLYPHDATA:String =
		" ☺☻♥♦♣♠●◘◉◙♂♀♪♬☼" +
		"►◄↕‼¶§▄↨↑↓→←∟↔▲▼"  +
		" !\"#$%&'()*+,-./" +
		"0123456789:;<=>?"  +
		"@ABCDEFGHIJKLMNO"  +
		"PQRSTUVWXYZ[\\]^_" +
		"`abcdefghijklmno"  +
		"pqrstuvwxyz{|}~⌂"  +
		"ÇüéâäaçêëèïîìÄÂ"   +
		"ÉæÆôöòûùÿÖÜc¢£¥₧ƒ" +
		"áíóúñÑªº¿⌐¬½¼¡«»";

	// Characters
	public static final DEFAULT_CHARACTER:String = "sonic";
	public static final LIFE_ICON:String = "liveIcon";

	/**
		Colors used to be replaced by other colors.
		This will not work with cached graphics!
	**/
	public static final PALETTE_OVERRIDE:Array<FlxColor> = [0xFF2020A0, 0xFF2040C0, 0xff4040E0, 0xff6060E0];

	/** (NOT IMPLEMENTED) Stores the velocity of super palettes when glowing into white in seconds **/
	public static final PALETTE_SUPER_VELOCITY = 1;

	// Save Select

	/** Number of Save Slots **/
	public static final SAVE_ENTRY_LIMIT:Int = 7;

	/**
		Colors used for tinting the "select" frame
		Color 1: Flash, Color 2: the actual frame color
	**/
	public static final SAVE_SELECTED_FRAME_COLOR:Array<FlxColor> = [0xffffffff, 0xffff0000];
	public static final SAVE_SELECTED_ARROW_COLOR:Array<FlxColor> = [0xffff0059, 0xffff0059];

	// Polymod
	public static final POLYMOD_SETTINGS:Dynamic = {
		useScriptedClasses: false
	};

	// Files
	/**
		Extension for Sound files that the game supports
		Must change per platform
	**/
	inline public static var SOUND_EXT = #if (web || flash) "mp3" #else "ogg" #end;

	/**
		Extension for Sound files that the game supports
		Must change per platform
	**/
	inline public static var VIDEO_EXT = "mp4";

	// Game - HUD
	inline public static var HUD_SCORE_MULTIPLIER:Float = 10.0;
	inline public static var HUD_RINGS_MAX:Int = 999;
	inline public static var HUD_LIVES_MAX:Int = 99;

	inline public static final LANGUAGE_DEFAULT:String = "en-US";
}

/**
	List of game sounds for easy management
**/
enum abstract ConstantSound(String) to String {
	@:inline var MENU_ACCEPT = "MenuAccept";
	@:inline var MENU_SCROLL = "MenuChange";
	@:inline var MENU_BACK   = "MenuCancel";

	@:inline var PLAYER_JUMP = "Jump";
	@:inline var PLAYER_ROLL = "Rolling";
	@:inline var PLAYER_TRANSFORM = "Transform";
	@:inline var PLAYER_HURT = "Hurt";
	@:inline var PLAYER_SPINDASH_C = "Charge";

	@:inline var RING = "Ring";

	@:inline var FAIL = "Fail";
}