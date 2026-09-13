/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-06-04
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/
package asthe.options;

import asthe.input.InputFormatter;
import asthe.options.Option;

using util.StringUtil;

import flixel.math.FlxMath;

class OptionsSubState extends SubStateManager {
	var selected:Int = 0;
	var options:Array<Option<Dynamic>>;

	public var camFront:FlxCamera;
	public var camFollow:FlxObject = new FlxObject(FlxG.width / 2, 0, 2, 2);

	var grpOptions:FlxTypedGroup<AstheText>;
	var grpValues:FlxTypedGroup<AstheText>;

	var txtDesc:AstheText;
	var sprDesc:AstheSprite;

	public var title:String;

	public function new() {
		super();

		title = !StringUtil.isBlank(title) ? Locale.getString("title_" + title, "options") : Locale.getString("title", "options");

		var bg = new AstheSprite().createGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		add(bg);

		camFront = new FlxCamera();
		camFront.bgColor = 0x00000000;
		camFront.follow(camFollow, LOCKON, 0.12);
		FlxG.cameras.add(camFront, false);

		var margin = 32;
		camFront.deadzone.set(0, margin, camFront.width, camFront.height - margin * 2);
		camFront.minScrollY = 0;

		grpOptions = new FlxTypedGroup<AstheText>();
		add(grpOptions);

		grpValues = new FlxTypedGroup<AstheText>();
		add(grpValues);

		add(camFollow);

		var title:AstheBitmapText = AstheBitmapText.createAngelCode(0, 8, title);
		title.screenCenter(X);
		add(title);

		if (!ArrayUtil.isBlank(options)) {
			/** Determines the spacement of the edges on the scrren **/
			var xFactor:Float = 0.9;
			for (i in 0...options.length) {
				var optName:AstheText = AstheText.create(FlxG.width - (FlxG.width * xFactor), 30, options[i].name);
				optName.fieldWidth = 170;
				optName.alignment = AstheText.TextAlign.LEFT;
				optName.ID = i;
				optName.y += (23 * i);
				optName.cameras = [camFront];
				grpOptions.add(optName);

				var optValues:AstheText = AstheText.create(FlxG.width * xFactor, optName.y, options[i].formatValue());
				optValues.fieldWidth = optName.fieldWidth;
				optValues.alignment = AstheText.TextAlign.RIGHT;
				optValues.x -= optValues.width; // Apply adjustment to fit screen factor
				optValues.color = optName.color;
				optValues.cameras = optName.cameras;
				grpValues.add(optValues);
			}
		}
		else {
			var warn:AstheText = AstheText.create(0, 0, Locale.getString("no_options", "options"));
			warn.screenCenter();
			add(warn);
		}

		sprDesc = new AstheSprite(0, FlxG.height * 0.7);
		var fillWidth = FlxG.height - sprDesc.y;
		sprDesc.createGraphic(FlxG.width, Std.int(fillWidth), FlxColor.BLACK);
		sprDesc.visible = (!ArrayUtil.isBlank(options));
		add(sprDesc);

		txtDesc = AstheText.create(0, sprDesc.y + 4, "");
		txtDesc.fieldWidth = FlxG.width;
		txtDesc.alignment = AstheText.TextAlign.CENTER;
		add(txtDesc);

		changeSelection();
	}

	override public function update(e:Float) {
		var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;
		var scroll = FlxG.mouse.wheel;
		if (controls.UP || controls.DOWN || scroll != 0) {
			changeSelection(((controls.UP ? -1 : controls.DOWN ? 1 : 0) - scroll) * mult);
		}

		if(controls.BACK) {
			close();
			AstheSound.playSound(ConstantSound.MENU_BACK);
		}

		if (controls.LEFT || controls.RIGHT) {
			if (ArrayUtil.isBlank(options))
				return;

			var change:Float = (controls.RIGHT ? 1 : -1) * mult;

			var opt = options[selected];
			opt.onChange(change);
			grpValues.members[selected].text = opt.formatValue();

			AstheSound.playSound(ConstantSound.MENU_SCROLL);
		}
	}

	override public function destroy() {
		super.destroy();

		if (camFront != null)
			FlxG.cameras.remove(camFront);
	}

	override public function close() {
		ClientPrefs.saveSettings();
		super.close();
	}

	public function addOption(option:Option<Dynamic>) {
		if(ArrayUtil.isBlank(options))
			options = [];

		options.push(option);
		return option;
	}

	function changeSelection(change:Int = 0) {
		if (ArrayUtil.isBlank(options) || ArrayUtil.isBlank(grpOptions.members)) {
			if (change != 0) AstheSound.playSound(ConstantSound.FAIL);
			return;
		}

		if (change != 0)
			AstheSound.playSound(ConstantSound.MENU_SCROLL);

		selected = FlxMath.wrap(selected + change, 0, options.length - 1);

		grpOptions.forEach(function(txt:AstheText) {
			txt.alpha = (txt.ID == selected) ? 1 : 0.5;

			if (txt.ID == selected)
				camFollow.y = txt.y;
		});

		txtDesc.text = options[selected].desc;
	}
}