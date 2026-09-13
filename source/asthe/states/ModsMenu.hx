/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-08-27
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.states;

#if MODS_ALLOWED
import polymod.Polymod;
#end
import openfl.display.BitmapData;

class ModsMenu extends StateManager {

	/*
		----------
		  NOTE
		----------
		Idk why but, this menu constantly keeps at bad performance
		if a mod is installed, and the source is on mod loading

		Idk how to increase the performance about that.
	*/

	#if MODS_ALLOWED
	var curSelected:Int = 0;
	var grpMods:FlxTypedGroup<ModEntry>;
	public var hasMods:Bool = false;
	var cachedMods:Array<ModMetadata> = [];

	var vers:AstheText = new AstheText(0, 0, "");
	var authors:AstheText = new AstheText(0, 0, "");
	var desc:AstheText = new AstheText(0, 0, "");

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence({details: Locale.getString('main_menu', 'discord')});
		#end

		if (Mods.cachedMods.length > 0 && cachedMods.length <= 0) {
			trace("User has cached mods!");
			cachedMods = Mods.cachedMods;
			hasMods = true;
		}
		else {
			trace("User doesn't have cached mods...");
			hasMods = !ArrayUtil.isBlank(cachedMods);
		}

		var bg:AstheSprite = AstheSprite.create(0, 0, "menus/mods/bg");
		add(bg);

		var titleTxt:AstheBitmapText = AstheBitmapText.createAngelCode(FlxG.width/2, 2, Locale.getString("title", "mods_menu"), "Roco");
		titleTxt.x -= (titleTxt.width/2);
		add(titleTxt);

		grpMods = new FlxTypedGroup<ModEntry>();
		add(grpMods);

		refreshList();

		if (hasMods) {
			var bottom:AstheSprite = AstheSprite.create(0, 156, "menus/mods/bottom");
			add(bottom);

			vers = AstheText.create(3, bottom.y + 2, "");
			add(vers);

			authors = AstheText.create(40, bottom.y + 2, "");
			add(authors);

			desc = AstheText.create(bottom.x + 4, bottom.y + 21, "");
			if (desc.fieldWidth > 420) // Idk if this saves memory or not
				desc.fieldWidth = 420; // 'cause the framework saves a HUGE
			if (desc.fieldHeight > 61) // BLANK SPRITE on the memory and not
				desc.fieldHeight = 61; // a resizable sprite one. (sounds obvious)
			add(desc);
		}
		else {
			var warn:AstheBitmapText = AstheBitmapText.createAngelCode(0, 90, Locale.getString("no_mods_warn", "mods_menu"), "Roco");
			warn.alignment = AstheText.TextAlign.CENTER;
			warn.screenCenter(X);
			add(warn);
		}

		super.create();
		changeItem(0);
		AstheSound.playMusic("MainMenu", { persist: true });
	}

	override function update(e:Float) {
		if (controls.BACK) {
			AstheSound.playSound(ConstantSound.MENU_BACK);
			FlxG.switchState(() -> new asthe.states.MainMenu());
		}

		if (hasMods) {
			var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;
			var scroll = FlxG.mouse.wheel;
			if (controls.UP || controls.DOWN || scroll != 0) {
				changeItem(((controls.UP ? -1 : controls.DOWN ? 1 : 0) - scroll) * mult);
			}
		}

		super.update(e);
	}

	function refreshList():Void {
		grpMods.clear();
		cachedMods = Mods.getAll();

		for (i in 0...cachedMods.length) {
			try {
				var mod:ModEntry = new ModEntry(5, 48, cachedMods[i]);
				mod.y += (21 * i);
				grpMods.add(mod);
			}
			catch (e:Dynamic) {
				trace('Error when adding mod to the list: {0}'.error(), e);
				return;
			}
		}

		updateModData();
	}

	function updateModData():Void {
		if (hasMods) {
			var m = cachedMods[curSelected];

			vers.text = "v" + m.modVersion;
			if (!ArrayUtil.isBlank(m.contributors)) // Help-  @unreal.sunnydev
				for (k in 0...m.contributors.length) {
					var names:Array<String> = [];
					names.push(m.contributors[k].name);

					authors.text = names.join(", ");

					if (authors.text.length > 43) { // Idk how to make it better lol, each gliph has a different width
						authors.text = authors.text.substring(0, authors.text.length - 3) + "...";
					}
				}
			else
				authors.text = Locale.getString("mod_info_no_contributors", "mods_menu");
			desc.text = (!StringUtil.isBlank(m.description)) ? m.description : Locale.getString("mod_info_no_description", "mods_menu");
		}
		else {
			trace("Cannot update mod data because theres no mods in the list!".error());
			return;
		}
	}

	function changeItem(idx:Int):Void {
		if (grpMods?.length <= 0 || !hasMods) {
			if (idx != 0) AstheSound.playSound(ConstantSound.FAIL);
			return;
		}

		if (idx != 0)
			AstheSound.playSound(ConstantSound.MENU_SCROLL);

		curSelected = FlxMath.wrap(curSelected + idx, 0, grpMods.length - 1);
		for (i in 0...grpMods.length) {
			var mod:ModEntry = grpMods.members[i];
			mod.selected = (i == curSelected);
		}

		updateModData();
	}
	#end
}

private class ModEntry extends FlxSpriteGroup {
	#if MODS_ALLOWED
	public var meta:ModMetadata;
	public var enabled:Bool;
	public var selected:Bool = false;

	public var icon:AstheSprite = new AstheSprite().createGraphic(18, 18, FlxColor.BLACK);
	public var text:AstheBitmapText = AstheBitmapText.createAngelCode(0, 0, "", "HUD");

	// Mod Meta Info
	public var compatible:Null<Bool> = true;

	var bg:flixel.addons.display.FlxSliceSprite;
	var unselectedRect:flixel.math.FlxRect = flixel.math.FlxRect.get(0, 0, 7, 7);
	var selectedRect:flixel.math.FlxRect = flixel.math.FlxRect.get(7, 0, 7, 7);

	/**
		The icon size to show on the menu
	**/
	var iconSize:Float = 18;

	public function new(x:Float = 0, y:Float = 0, ?meta:Null<ModMetadata> = null) {
		super();

		if (meta != null) {
			this.meta = meta;
			this.compatible = (meta.apiVersion == flixel.FlxG.stage.application.meta.get("version"));

			trace("Loading mod icon... (" + meta.id + ")");
			if (meta.icon != null) {
				icon.loadGraphic(openfl.display.BitmapData.fromBytes(meta.icon));
				trace("Loaded!");
			}
			else {
				icon.loadGraphic(Paths.image("menus/mods/unknownMod"));
				trace("Mod doesn't have a icon...");
			}
		}

		bg = AstheSprite.createSliced(x, y, 416, 18, "UI/button", [3, 3, 1, 1], [0, 0, 7, 7]);
		add(bg);

		icon.setPosition(x + 5, y - 1);
		icon.scale.set(iconSize / icon.width, iconSize / icon.height);
		icon.updateHitbox();
		add(icon);

		var border:AstheSprite = AstheSprite.create(icon.x - 1, icon.y - 1, "menus/mods/iconBorder");
		add(border);

		text.x = x + 34;
		text.y = y + 4;
		text.text = (meta.title).toUpperCase(); // our modifier doesn't works, and we can't override setter functions....
		add(text);
	}

	override public function update(e:Float) {
		super.update(e);

		bg.sourceRect = (selected) ? selectedRect : unselectedRect;
		icon.color    = (selected) ? FlxColor.WHITE : FlxColor.RED;
		text.alpha    = (selected) ? 1 : 0.5;
	}
	#end
}