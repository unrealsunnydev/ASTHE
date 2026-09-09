/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-08-27
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.states;

import asthe.backend.StateManager;
import asthe.options.OptionsState;

import flixel.addons.plugin.FlxScrollingText;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.input.mouse.FlxMouse;

class MainMenu extends StateManager {
	public static var curSelected:Int = 0;

	var group:FlxTypedGroup<AstheBitmapText>;
	var options:Array<String> = [
		"Save Select",
		"Options",
		#if MODS_ALLOWED "Mods", #end
		"Exit"
	];

	override function create() {
		Paths.clearStoredMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence({details: Locale.getString('main_menu', 'discord')});
		#end

		var bg:flixel.FlxSprite = AstheSprite.createGradient(FlxG.width, FlxG.height, [0xFF793BFF, 0xFF95EDFF], 4, 32, false);
		add(bg);

		var bgLayer:AstheSprite = new AstheSprite().createGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgLayer.alpha = ClientPrefs.data.options.backLayers;
		add(bgLayer);

		var backd:FlxBackdrop = new FlxBackdrop(Paths.image("UI/backdropX"), X);
		backd.y = 15;
		backd.flipY = true;
		backd.color = (ClientPrefs.data.options.accentColors ? SystemUtil.ACCENT_COLOR : FlxColor.YELLOW);
		backd.dirty = true;
		backd.velocity.set(-30, 0);
		add(backd);

		var backdFill:AstheSprite = new AstheSprite().createGraphic(FlxG.width, Math.floor(backd.y), 0xFFFFFFFF);
		backdFill.color = backd.color;
		backdFill.alpha = backd.alpha;
		backdFill.dirty = backd.dirty;
		add(backdFill);

		var titleTxt:AstheBitmapText = AstheBitmapText.createAngelCode(0, 2, Locale.getString("title", "main_menu"), "HUD");

		var titleSpr = FlxScrollingText.add(titleTxt, new openfl.geom.Rectangle(0, 2, FlxG.width, titleTxt.height));
		add(titleSpr);
		FlxScrollingText.startScrolling(titleSpr);

		var version:AstheBitmapText = AstheBitmapText.createMonospace(FlxG.width, FlxG.height, "v" + FlxG.stage.application.meta.get("version"),
			"AbsoluteSystem", Constants.ABSOLUTE_FONT_GLYPHDATA, [8, 8]);

		final buildNumber = flixel.FlxG.stage.application.meta.get("buildNumber");
		if (!StringUtil.isBlank(buildNumber)) {
			version.text += " " + buildNumber;
		}
		version.x -= (version.width + 7);
		version.y -= (version.height + 2);
		add(version);

		var commit:AstheBitmapText = AstheBitmapText.createMonospace(FlxG.width, version.y, Constants.GIT_COMMIT_HASH, "AbsoluteSystem", Constants.ABSOLUTE_FONT_GLYPHDATA, [8, 8]);
		commit.x -= (commit.width + 7);
		commit.y -= commit.height;
		add(commit);

		group = new FlxTypedGroup<AstheBitmapText>();
		add(group);

		for (num => str in options) {
			var menu:AstheBitmapText = AstheBitmapText.createAngelCode(10, 30, Locale.getString(str, "main_menu"), "HUD");
			menu.x += (32 * num);
			menu.y += (18 * num);
			menu.ID = num;
			group.add(menu);
		}

		// Testing asset with Polymod and FireTongue but seems it doesn't work :P
		var test:AstheSprite = AstheSprite.create(0, 0, "assetTest");
		test.screenCenter();
		add(test);

		super.create();
		changeItem();
		AstheSound.playMusic("MainMenu", { persist: true });
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float) {
		if (!selectedSomethin) {
			var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;
			var scroll = FlxG.mouse.wheel;
			if (controls.UP || controls.DOWN || scroll != 0) {
				changeItem(((controls.UP ? -1 : controls.DOWN ? 1 : 0) - scroll) * mult);
			}

			if (controls.ACCEPT) {
				selectedSomethin = true;
				selectItem(options[curSelected]);
			}

			if (controls.BACK) {
				AstheSound.playSound(ConstantSound.MENU_BACK);
				FlxG.switchState(() -> new TitleState());
			}
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(() -> new asthe.states.editor.MainMenuEdt());
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0) {
		if (ArrayUtil.isBlank(options) || group.length == 0) {
			if (change != 0) AstheSound.playSound(ConstantSound.FAIL);
			return;
		}

		if (change != 0)
			AstheSound.playSound(ConstantSound.MENU_SCROLL);

		curSelected = FlxMath.wrap(curSelected + change, 0, group.length - 1);

		group.forEach(function(txt:FlxBitmapText) {
			txt.color = (txt.ID == curSelected) ? 0xFFFF0000 : 0xFFFFFFFF;
		});
	}

	function selectItem(choice:String = "") {
		choice = choice.toLowerCase();

		if (choice == 'exit') {
			#if sys
			AstheSound.playSound(ConstantSound.MENU_ACCEPT);
			#else
			AstheSound.playSound(ConstantSound.FAIL);
			#end
		}
		else
			AstheSound.playSound(ConstantSound.MENU_ACCEPT);

		group.forEach(function(txt:FlxBitmapText) {
			if (curSelected == txt.ID) {
				FlxFlicker.flicker(txt, 1, (!ClientPrefs.data.options.flashing) ? 0.3 : 0.06, false, false, function(flick:FlxFlicker) {

					switch (choice) {
						case 'save select':
							LoadingState.switchStates(new SaveSelect(), true);
						case 'options':
							LoadingState.switchStates(new asthe.options.OptionsState());
							OptionsState.onPlayState = false;
						case 'mods':
							LoadingState.switchStates(new ModsMenu());
						case 'exit':
							#if sys
							Sys.exit(0);
							#end
					}
				});
			}
		});
	}
}