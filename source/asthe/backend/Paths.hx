package asthe.backend;

import flixel.math.FlxPoint;
import flash.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.geom.Rectangle;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

/**
	@see https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/backend/Paths.hx
**/
@:access(openfl.display.BitmapData)
class Paths {
	inline public static final DEFAULT_LIBRARY = "default";


	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/music/MainMenu.${Constants.SOUND_EXT}'];
	// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				destroyGraphic(currentTrackedAssets.get(key)); // get rid of the graphic
				currentTrackedAssets.remove(key); // and remove the key from local cache map
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory() {
		// clear anything not in the tracked assets list
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}

	public static function freeGraphicsFromMemory() {
		var protectedGfx:Array<FlxGraphic> = [];
		function checkForGraphics(spr:Dynamic) {
			try {
				var grp:Array<Dynamic> = Reflect.getProperty(spr, 'members');
				if(grp != null) {
					for (member in grp) {
						checkForGraphics(member);
					}
					return;
				}
			}

			//trace('check...');
			try {
				var gfx:FlxGraphic = Reflect.getProperty(spr, 'graphic');
				if(gfx != null) {
					protectedGfx.push(gfx);
					//trace('gfx added to the list successfully!');
				}
			}
			//catch(haxe.Exception) {}
		}

		for (member in FlxG.state.members)
			checkForGraphics(member);

		if(FlxG.state.subState != null)
			for (member in FlxG.state.subState.members)
				checkForGraphics(member);

		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!dumpExclusions.contains(key)) {
				var graphic:FlxGraphic = currentTrackedAssets.get(key);
				if(!protectedGfx.contains(graphic)) {
					destroyGraphic(graphic); // get rid of the graphic
					currentTrackedAssets.remove(key); // and remove the key from local cache map
					//trace('deleted $key');
				}
			}
		}
	}

	inline static function destroyGraphic(graphic:FlxGraphic) {
		// free some gpu memory
		graphic?.bitmap?.__texture?.dispose();
		FlxG.bitmap.remove(graphic);
	}

	static var currentLevel:Null<String> = null;
	static public function setCurrentLevel(name:Null<String>):Void {
		currentLevel = (name.isBlank()) ? null : name.toLowerCase();
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null):String {
		if (!library.isBlank()) {
			return getLibraryPath(file, library);
		}

		if (!currentLevel.isBlank()) {
			var levelPath:String = getLibraryPath(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getLibraryPath(file);
	}

	/**
		Returns a path from the assets folder
		@param file
		@param folder The folder to use (@default `"default"`)
		@return String
	**/
	inline static public function getLibraryPath(file:String = '', library = DEFAULT_LIBRARY, ?forceLib:Bool = false):String {
		if (library == DEFAULT_LIBRARY && !forceLib) {
			return "assets/" + file;
		}

		return '$library:assets/$library/$file';
	}

	inline static public function video(key:String) {
		return getPath('videos/$key.${Constants.VIDEO_EXT}');
	}

	inline static public function sound(key:String):Sound {
		return returnSound('sounds/$key');
	}

	inline static public function soundRandom(key:String, min:Int, max:Int) {
		return sound(key + FlxG.random.int(min, max));
	}

	inline static public function music(key:String):Sound {
		return returnSound('music/$key');
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	/**
		Gets a image
		@param key Name of the image (e.g. funkay)
		@param parentFolder Use another folder? (Default: Shared)
		@param allowGPU Cache on GPU? (Default: True)
		@return FlxGraphic
	**/
	public static function image(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxGraphic {
		#if TRANSLATIONS_ALLOWED
		key = Locale.getFile('images/$key', 'png');
		#end
		var bitmap:BitmapData = null;
		if (currentTrackedAssets.exists(key)) {
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		return cacheBitmap(key, parentFolder, bitmap, allowGPU);
	}

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:Null<BitmapData>, ?allowGPU:Bool = true):FlxGraphic {
		if (bitmap == null) {
			var file:String = getPath(key, IMAGE, parentFolder);

			if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);

			if (bitmap == null) {
				trace('Bitmap not found: {0} | key: {1}', file, key);
				return null;
			}
		}

		if (allowGPU && ClientPrefs.data.options.cacheOnGPU && bitmap.image != null) {
			bitmap.lock();
			if (bitmap.__texture == null) {
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}

		var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}

	/**
		Gets the path for font files
		@param key The font filename
		@return getPath():String
	**/
	inline static public function font(key:String) {
		#if TRANSLATIONS_ALLOWED
		key = Locale.tongue.getFontData(key).name;
		#end

		return getPath("fonts/" + key);
	}

	inline static public function getSparrowAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		var imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath(Locale.getFile('images/$key', 'xml'), TEXT, parentFolder));
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(key:String, ?path:String, ?beepOnNull:Bool = true) {
		var file:String = getPath(
			#if TRANSLATIONS_ALLOWED
			Locale.getFile(key, Constants.SOUND_EXT),
			#else
			key + "." + Constants.SOUND_EXT,
			#end
		SOUND, path);

		//trace('precaching sound: $file');
		if(!currentTrackedSounds.exists(file)) {
			if(OpenFlAssets.exists(file, SOUND))
				currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
			else if(beepOnNull) {
				trace("SOUND NOT FOUND: {0}, PATH: {1}".error(), key, path);
				FlxG.log.error('SOUND NOT FOUND: $key, PATH: $path');
				#if (flixel >= "5.9.0")
				return FlxAssets.getSoundAddExtension('flixel/sounds/beep');
				#else
				return FlxAssets.getSound('flixel/sounds/beep');
				#end
			}
		}
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}

	/**
		Checks if a file exists or not
		@param key The file path with extension
		@param type OpenFL Asset Type
		@param library Does it is stored on another folder?
		@return Bool
	**/
	inline public static function fileExists(key:String, type:AssetType, ?library:String = null):Bool {
		var path = getPath(key, type, library);

		if(OpenFlAssets.exists(path, type)) {
			return true;
		}

		trace("File doesn't exists: {0} | path: {1}".error(), key, path);
		return false;
	}

	/**
		Gets the content of a file
		@param key File name or path to the file
		@return Null<String>
	**/
	inline static public function getContent(key:String):Null<String> {
		if (fileExists(key, TEXT))
			return Assets.getText(getPath(key));
		else {
			trace("Cannot get the content of '{0}'".error(), key);
			return null;
		}
	}

	/**
		Parses an JSON file
		@param path Path to json name (e.g. 'data/MyData.json')
		@return Dynamic
	**/
	public static function parseJson(path:String):Dynamic {
		return haxe.Json.parse(getContent(path));
	}
}