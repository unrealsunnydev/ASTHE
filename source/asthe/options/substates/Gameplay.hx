/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-06-04
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.options.substates;

class Gameplay extends OptionsSubState {
	public function new() {
		title = "Gameplay";

		addOption(new BoolOption("auto_pause", "autoPause"));
		addOption(new BoolOption("flashing_lights", "flashing"));
		addOption(new BoolOption("hide_hud", "hideHud"));
		addOption(new BoolOption("show_miliseconds", "showMiliseconds"));
		super();
	}
}