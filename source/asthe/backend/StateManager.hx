package asthe.backend;

import flixel.FlxState;

/** @see https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/backend/MusicBeatState.hx **/
class StateManager extends FlxState {
public var controls(get, never):Controls;
	private function get_controls() {
		return Controls.instance;
	}

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables()
		return getState().variables;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		super.create();

		if(!skip) openSubState(new CustomFadeTransition(0.5, true));
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float) {
		if (FlxG.save.data?.fullscreen != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);

		/*
		if (FlxG.keys.justPressed.F5) {
			hotReload();
		} */

	}

	/* // Disabled until fix soon
	public static function hotReload():Void {
			trace("HOT RELOAD");
			Paths.clearStoredMemory();
			Paths.clearUnusedMemory();
			Locale.init();

			if (ClientPrefs.data.options.accentColors)
				SystemUtil.ACCENT_COLOR = SystemUtil.loadAccentColor();

			FlxG.resetState();
			return;
	}*/

	public static function getState():StateManager {
		return cast (FlxG.state, StateManager);
	}
}
