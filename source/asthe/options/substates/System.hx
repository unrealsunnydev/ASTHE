/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-06-04
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.options.substates;

class System extends OptionsSubState {
	public function new() {
		title = Locale.getString("title_system", "options");

		addOption(new BoolOption("cache_on_gpu", "cacheOnGPU"));
		#if DISCORD_ALLOWED
		addOption(new BoolOption("discord_rich_presence", "discordRPC"));
		#end
		addOption(new BoolOption("haptics", "haptics"));
		#if sys
		addOption(new BoolOption("accent_colors", "accentColors"));
		#end
		#if shaders_supported
		addOption(new BoolOption("shaders", "shaders"));
		#end
		addOption(new BoolOption("low_quality", "lowQuality"));
		addOption(new NumberOption("music_volume", "musicVolume", 40, 0, 1, 0.1, true));
		addOption(new NumberOption("sfx_volume", "sfxVolume", 40, 0, 1, 0.1, true));

		super();
	}
}