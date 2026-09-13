package asthe.states.editor;

// This menu is unused by now, but soon we'll get
// some cool game tools for editing anything on the game.

class MainMenuEdt extends StateManager {
	var selected:Int = 0;
	var group:FlxTypedGroup<AstheText>;
	var options:Array<String> = ["Character Editor"];

	override public function create() {
		var bg:flixel.FlxSprite = AstheSprite.createGradient(FlxG.width, FlxG.height, [0xFF353535, 0xFF979797], 4, 32, false);
		add(bg);

		group = new FlxTypedGroup<AstheText>();
		add(group);

		if (!ArrayUtil.isBlank(options)) {
			for (num => str in options) {
				var menu:AstheText = AstheText.create(10, 30, Locale.getString("title_" + str, "editor_menu"));
				menu.format(16, "center", FlxColor.WHITE);
				menu.y += (18 * num);
				menu.ID = num;
				group.add(menu);
			}
		}
		else {
			var warn:AstheText = AstheText.create(0, 0, Locale.getString("no_options", "editor_menu", [asthe.input.InputFormatter.getControlNames(asthe.input.InputList.ACCEPT)]));
			warn.screenCenter();
			add(warn);
		}

		super.create();
		changeItem();
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float) {
		if (!selectedSomethin) {

			var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;
			var scroll = FlxG.mouse.wheel;
			if (controls.UP || controls.DOWN || scroll != 0) {
				changeItem(((controls.UP ? -1 : 1) * mult) - scroll);
				AstheSound.playSound(ConstantSound.MENU_SCROLL);
			}

			if (controls.ACCEPT) {
				if (ArrayUtil.isBlank(options))
					return;

				AstheSound.playSound(ConstantSound.MENU_ACCEPT);
				selectedSomethin = true;

				switch(options[selected].toLowerCase()) {
					case "character editor":
						LoadingState.switchStates(new asthe.states.editor.CharacterEdt());
				}

			}

	  		if (controls.BACK) {
				AstheSound.playSound(ConstantSound.MENU_BACK);
				FlxG.switchState(() -> new asthe.states.MainMenu());
			}
		}
		super.update(elapsed);
	}

	function changeItem(change:Int = 0) {
		if (ArrayUtil.isBlank(options) || ArrayUtil.isBlank(group.members))
			return;

		selected = FlxMath.wrap(selected + change, 0, group.length - 1);

		group.forEach(function(txt:AstheText) {
			txt.color = (txt.ID == selected) ? 0xFF002896 : 0xFFFFFFFF;
		});
	}
}