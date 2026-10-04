package asthe.backend;

import firetongue.FireTongue;

using util.StringUtil;

/**
	Handler for translating text and assets in the game

	@author Sunnydev31 (unreal.sunnydev)
**/
//@:nullSafety
class Locale {
	public static var tongue:Null<FireTongue> = null;

	/**
		Gets an translation phrase
		@param key String key on files
		@param defaultPhrase Phrase in English
		@param values Any phrase that has "`{1}`, `{2}`..." will be replaced with any value inserted following a sequence
		@return String
	**/
	inline public static function getString(key:String = "", context:String = "data", ?values:Array<Dynamic> = null):String {
		var str:String = (key.isBlank()) ? "[!]" : key;

		if (tongue != null) {
			str = tongue.get(formatKey(key), context, true);

			if (!ArrayUtil.isBlank(values)) {
				str = str.format(values);

				if (str == formatKey(key)) {
					trace("Context '{0}' has a file with missing flags! ({1})".warn(), context, key);
				}
			}
		}

		return str;
	}

	/**
		Gets a translatable file, More optimized for file loading
		@param key Default file path
		@param extension File extension to add ("txt", "png"...), "." will be added automatically
		@return String
	**/
	inline public static function getFile(key:String, ?extension:String = ""):String {
		if (key.isBlank()) throw "Unable to find a file because the key is null/empty!";

		var str:String = tongue?.get(key.trim(), "files") ?? key;

		if (!StringUtil.isBlank(extension))
			str += "." + extension;

		return str;
	}

	/**
		Formats the localization key string 
		@param key The key to format
	**/
	inline static private function formatKey(key:Null<String>) {
		final hideChars = ~/[~&\\\/;:<>#.,'"%?!]/g;
		key ??= "";
		return hideChars.replace(key.replace(' ', '_'), '').trim().toLowerCase();
	}

	/**
		Initializes the localization system.

		If you want to change the Firetongue's configuration,
		checkout this function!
	**/
	public static function init() {
		tongue ??= new FireTongue(OPENFL, Case.Unchanged);

		tongue.initialize({
			locale: (ClientPrefs.data.options.language ?? Constants.LANGUAGE_DEFAULT),
			replaceMissing: true,
			checkMissing: true,
			finishedCallback: onLoad
		});
	}

	/** Callback when FireTongue loads the locale. **/
	public static function onLoad():Void {
		trace("Loaded! Locale: '{0}'".info(), (tongue?.locale ?? "not loaded!"));
	}
}