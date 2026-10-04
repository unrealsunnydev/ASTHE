package;

import flixel.FlxGame;
import firetongue.FireTongue;
import openfl.display.Sprite;

import openfl.events.UncaughtErrorEvent;

class Main extends Sprite {
	public var GAME:Dynamic = {
		width: 426,
		height: 240,
		initState: asthe.states.Init,
		fps: 60
	}

	public function new() {
		super();

		function logFormat(v:Dynamic, infos:Null<haxe.PosInfos>):String {
			var str = Std.string(v);

			if (infos == null)
				return str;

			var pstr = '[${infos.className}::${infos.methodName}:${infos.lineNumber}]';
			if (infos.customParams != null)
				str = str.format(infos.customParams);

			return pstr + " " + str;
		}

		final date = DateTools.format(Date.now(), "%F_%H-%M-%S");
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos):Void {
			var msg = logFormat(v, infos);

			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log(msg);
			#elseif lua
			untyped __define_feature__("use._hx_print", _hx_print(msg));
			#elseif sys
			Sys.println(msg);

			// Save into a log file
			Ansi.enabled = false;
			FileUtil.appendToFile("./logs/log_" + date + ".txt", msg + "\n");
			Ansi.enabled = Ansi.isSupported();
			#else
			throw new haxe.exceptions.NotImplementedException();
			#end
		}

		#if android
		Sys.setCwd(haxe.io.Path.addTrailingSlash(extension.androidtools.content.Context.getObbDir())); // stupid android 16
		#end

		// Load the accent color
		SystemUtil.ACCENT_COLOR = SystemUtil.loadAccentColor();

		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();

		FlxG.save.bind('game', ClientPrefs.getSavePath());

		openfl.utils._internal.Log.level = openfl.utils._internal.Log.LogLevel.INFO;

		var game:FlxGame = new FlxGame(GAME.width, GAME.height, GAME.initState, #if (flixel < "5.0.0") 1, #end GAME.fps, GAME.fps, true);

		#if web
		// Tells the HTML to use pixelated images
		lime.app.Application.current.window.element.style.setProperty("image-rendering", "pixelated");
		#end

		Locale.tongue = new FireTongue(OPENFL, Case.Unchanged);

		addChild(game);

		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	public static function onCrash(e:UncaughtErrorEvent) {
		final folderPath:String = "./crash/";
		var date:String = DateTools.format(Date.now(),
			Locale.getString("format_date", null, ["-", "-"]) + "_" + Locale.getString("format_hour", null, ["-", "-"]));

		var msg:String = "Error!\n";

		msg += e.error + "\n\nReport this in Github: " + Constants.GIT_REPO_URL + "/issues";

		#if sys
		FileUtil.saveContent(folderPath + Constants.GIT_REPO_PROJECT + "_" + date + ".log", msg);

		Sys.println(msg);
		#end

		lime.app.Application.current.window.alert(msg, "Something is wrong...");

		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end

		#if sys
		Sys.exit(1);
		#end
	}
}
