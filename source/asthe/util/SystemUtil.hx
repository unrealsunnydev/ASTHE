package asthe.util;

import openfl.system.Capabilities;
import lime.system.System as LimeSystem;

import haxe.io.Path;
#if sys
import sys.io.Process;
#end

class SystemUtil {
	@:isVar
	public static var ACCENT_COLOR(get, set):FlxColor = 0xFFFFFF;

	/**
		Returns the Directory Separator character  
		`\` on Windows, `/` on other systems.
	**/
	inline public static final DIRECTORY_SEPARATOR:String = #if windows "\\"; #else "/"; #end

	/**
		Returns the Invalid Directory Separator character, used for replacing
		incorrect chars on a path.

		`/` on Windows, `\` on other systems.
	**/
	inline public static final DIRECTORY_SEPARATOR_REPL:String = #if windows "/"; #else "\\"; #end

	/**
		Returns a Regex of invalid characters file names used on paths.

		Windows: `\ / : * ? " < > |`  
		Unix: `/`
	**/
	public static final INVALID_PATH_CHARS:EReg =
	#if windows
	new EReg("[\\/:*?\"<>|]", "g");
	#else
	new EReg("/", "g");
	#end

	/**
		Opens a folder on your system file manager
	**/
	inline public static function openFolder(folder:String, ?absolute:Null<Bool> = false):Void {
		#if sys
		if(!absolute) folder =  Sys.getCwd() + folder;

		folder = Path.removeTrailingSlashes(folder.replace(DIRECTORY_SEPARATOR_REPL, DIRECTORY_SEPARATOR));

		#if (cpp)
		var command:String = "";
		#if mac
		command = "/usr/bin/open";
		#elseif linux
		command = '/usr/bin/xdg-open';
		#elseif windows
		command = 'explorer.exe';
		#end

		Sys.command(command, [folder]);
		trace('Command $command, Folder $folder');
		#end

		#else
		FlxG.log.error("Platform is not supported for SystemUtil.openFolder");
		#end
	}

	/**
		Opens a URL on a browser, or a new tab
		if the browser are currently started.
	**/
	inline public static function browserLoad(site:String):Void {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	@:privateAccess() private static var _accent:Int = 0xFFFFFF;

	/**
		Loads the current accent color of the system

		Accessible through `SystemUtil.ACCENT_COLOR`

		EXAMPLE:
		```haxe
		var blankSpr:AstheSprite = new AstheSprite().createGraphic(10,10, 0xFFFFFFFF);
		blankSpr.color = (ClientPrefs.data.options.accentColor) ? SystemUtil.ACCENT_COLOR : FlxColor.LIME;
		```

		Remember that you need to use a "default color" because this function is limited per system!
	**/
	inline public static function loadAccentColor():Null<Int> {
		trace("Loading accent colors...".info());

		function loadBlankColor():Int {
			var errorMsg:String = "You're using a environment that doesn't support accent colors!";
			#if no_traces // Prevent it to call trace() again
			FlxG.log.error(errorMsg);
			#else
			trace(errorMsg.error());
			#end
			return 0xFFFFFF;
		}

		#if sys
		var p:Process;
		#end

		#if (windows && sys)
		// Run a command to get the value
		p = new Process("reg", ["query", "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent", "/v", "AccentColorMenu"]);
		var result:String = p.stdout.readAll().toString();
		p.close();

		// Conversion from ABRG to ARGB
		var accent:String = ColorUtil.convertToHex(result.split("    ")[3].trim(), false, true);

		trace('Loaded!'#if debug + '\nParsed: . $accent\nOriginal: $r'#end.info());
		return Std.parseInt(accent);
		#elseif linux
		final HOME:String = Sys.getEnv("HOME");

		// TODO: Add support to GNOME, XFCE and more.
		switch (getDesktop()) {
			case "KDE":
				trace("Linux Desktop is KDE Plasma".info());

				// Read "$HOME/.config/kdeglobals" file
				var cfg = File.getContent(Path.join([HOME, ".config", "kdeglobals"]));
				var rawAccent = cfg.substr(cfg.indexOf("AccentColor") + 12).split("\n")[0].split(",");

				var accent = "0x" + StringTools.hex(Std.parseInt(rawAccent[0]), 2);
				accent += StringTools.hex(Std.parseInt(rawAccent[1]), 2);
				accent += StringTools.hex(Std.parseInt(rawAccent[2]), 2);

				trace('Loaded!'#if debug + '\nParsed: . $accent\nOriginal: $rawAccent'#end.info());
				return Std.parseInt(accent);
			/*
			case "GNOME":
				trace("Linux Desktop is GNOME".info());
			case "CINNAMON":
				trace("Linux Desktop is Cinnamon".info());
			case "XFCE":
					trace("Linux Desktop is XFCE".info());
			*/
			default:
				return loadBlankColor();
		}
		#elseif (mac || !sys) // I don't know how accent colors works on other systems...
		return loadBlankColor();
		#end
	}

	private static function get_ACCENT_COLOR():Int {
		return _accent;
	}

	private static function set_ACCENT_COLOR(value:Null<Int>):Int {
		if (value == null) {
			trace("Value for accent color is null!".warn());
		}

		_accent = value ?? 0xFFFFFF;
		return _accent;
	}

	public static function getSystemName():String {
		return LimeSystem.platformName;
	}

	/**
		Gets the current desktop environment you're using on Linux: KDE Plasma, GNOME, Cinnamon...

		DOES NOT WORK WITH WINDOWS AND MACOS
	**/
	public static function getDesktop():Null<String> {
		#if linux
		var x = Std.string(Sys.getEnv("XDG_CURRENT_DESKTOP")).toUpperCase();
		if (x.contains("KDE") || x.contains("PLASMA")) return "KDE";
		if (x.contains("GNOME")) return "GNOME";
		if (x.contains("CINNAMON")) return "CINNAMON";
		if (x.contains("XFCE")) return "XFCE";
		return null;
		#else
		return null;
		#end
	}
}