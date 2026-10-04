/*
	Sunnydev31 (@unreal.sunnydev) - Last Edition: 2026-06-04
	You are allowed to use, modify and redistribute this code
	Credit is not needed, but are appreciated.
*/

package asthe.states;

import asthe.objects.Character;
import flixel.tween.*;

class SaveSelect extends StateManager {
	public var camFront:FlxCamera;
	public var camFollow:FlxObject = new FlxObject(FlxG.width / 2, 0, 2, 2);

	public var saveGroup:FlxTypedGroup<SaveEntry>;
	var curSlot:Int = 0;
	var curChar:Int = 0;
	var curZone:Int = 0;

	var selectSave:AstheSprite;
	var arrow1:AstheSprite;
	var arrow2:AstheSprite;
	var arrow3:AstheSprite;
	var arrow4:AstheSprite;

	public static var charList:Array<String>;

	override function create() {
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		reloadCharacters();

		saveGroup = new FlxTypedGroup<SaveEntry>();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence({ details: Locale.getString('save_select', 'discord') });
		#end

		camFront = new FlxCamera();
		camFront.visible = true;
		camFront.bgColor.alpha = 5;
		FlxG.cameras.add(camFront, false);
		camFront.follow(camFollow, LOCKON, 0.12);

		var bg:AstheSprite = AstheSprite.create(0, 0, "menus/saveSelect/bg");
		add(bg);

		var bgLayer:AstheSprite = new AstheSprite().createGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgLayer.alpha = ClientPrefs.data.options.backLayers;
		add(bgLayer);

		var title:AstheBitmapText = AstheBitmapText.createAngelCode(FlxG.width/2, FlxG.height - 26, Locale.getString("title", "save_select"), "GameOver");
		title.x -= title.width / 2;
		add(title);

		for (i in 0...Constants.SAVE_ENTRY_LIMIT) {
			var saveEntry:SaveEntry = new SaveEntry(i);
			saveEntry.setPosition(90 * i, 80);
			saveEntry.cameras = [camFront];
			saveGroup.add(saveEntry);
		}
		add(saveGroup);

		//Do not touch the position of this sprite
		selectSave = AstheSprite.create(saveGroup.members[curSlot].x, saveGroup.members[curSlot].y, "menus/saveSelect/selected");
		FlxTween.color(selectSave, 0.2, Constants.SAVE_SELECTED_FRAME_COLOR[0], Constants.SAVE_SELECTED_FRAME_COLOR[1], {type: FlxTweenType.PINGPONG, ease: FlxEase.linear});
		selectSave.cameras = [camFront];
		add(selectSave);

		// Positions of all the sprites above are updated on `changeSlot()`
		arrow1 = AstheSprite.create(0, 0, "menus/saveSelect/selectArrow");
		arrow1.color = Constants.SAVE_SELECTED_ARROW_COLOR[0];
		arrow1.cameras = [camFront];
		add(arrow1);

		arrow2 = AstheSprite.create(0, 0, "menus/saveSelect/selectArrow");
		arrow2.color = Constants.SAVE_SELECTED_ARROW_COLOR[1];
		arrow2.cameras = [camFront];
		add(arrow2);

		arrow3 = AstheSprite.create(0, 0, "menus/saveSelect/selectArrowFlip");
		arrow3.color = arrow1.color;
		arrow3.cameras = [camFront];
		add(arrow3);

		arrow4 = AstheSprite.create(0, 0, "menus/saveSelect/selectArrowFlip");
		arrow4.color = arrow2.color;
		arrow4.cameras = [camFront];
		add(arrow4);

		changeSlot();

		super.create();
		AstheSound.playMusic("SaveSelect");
	}

	override function update(e:Float) {
		super.update(e);

		if (controls.ACCEPT) {
			if (getSaveState(curSlot) == InProgress) {
				ClientPrefs.loadSlot(curSlot);
				LoadingState.switchStates(new asthe.states.PlayState(), true);
			}
			else {
				ClientPrefs.createSlot(curSlot, Constants.DEFAULT_CHARACTER);
				LoadingState.switchStates(new asthe.states.PlayState(), true);
			}
		}

		if (controls.BACK)
			FlxG.switchState(() -> new asthe.states.MainMenu());

		if (controls.UP || controls.DOWN) {
			switch (getSaveState(curSlot)) {
				case New:
					changeCharacter(controls.UP ? -1 : 1);
				default:
			}
		}

		if (controls.LEFT || controls.RIGHT) {
			changeSlot(controls.LEFT ? -1 : 1);
		}
	}

	function reloadCharacters():Void {
		charList = [];

		for (char in openfl.utils.Assets.list(TEXT)) {
			if (char.contains("data/characters/") && char.endsWith(".json")) {
				var ind = char.lastIndexOf("/");
				var name = char.substring(ind + 1, char.length - 5);

				// We don't need to add that name again
				if (charList.contains(name))
					continue;
				else {
					trace("Added char: " + name);
					charList.push(name);
				}
			}
		}
	}

	function changeSlot(count:Int = 0) {
		if (ArrayUtil.isBlank(saveGroup.members)) {
			if (count != 0) AstheSound.playSound(ConstantSound.FAIL);
			return;
		}

		if (count != 0)
			AstheSound.playSound(ConstantSound.MENU_SCROLL);

		curSlot = FlxMath.wrap(curSlot + count, 0, saveGroup.length - 1);

		var member = cast saveGroup.members[curSlot];
		if (member == null) {
			trace("member is null!".warn());
			return;
		}

		selectSave.setPosition  (member.x, member.y);
		arrow1.setPosition      (selectSave.x + (member.width / 2), member.y + 14);
		arrow2.setPosition      (selectSave.x + (member.width / 2), member.y + 65);
		arrow3.setPosition      (selectSave.x + (member.width / 2), arrow1.y + 18);
		arrow4.setPosition      (selectSave.x + (member.width / 2), arrow2.y + 30);

		camFollow.setPosition(selectSave.x + (selectSave.width / 2), selectSave.y + (selectSave.height / 2));
	}

	function changeCharacter(count:Int = 0) {
		if (SaveEntry.instance == null || ArrayUtil.isBlank(charList)) {
			if (count != 0) AstheSound.playSound(ConstantSound.FAIL);
			return;
		}

		if (count != 0)
			AstheSound.playSound(ConstantSound.MENU_SCROLL);

		curChar = FlxMath.wrap(curChar + count, 0, charList.length - 1);

		saveGroup.members[curSlot].character.loadGraphic("menus/saveSelect/characters/" + charList[curChar]);
	}

	static function getSaveState(slot:Int):SaveState {
		if (!ClientPrefs.slotExists(slot)) return New;
		else if (ClientPrefs.loadSlotData(slot).clear) return Clear;
		return InProgress;
	}
}

@:nullSafety
class SaveEntry extends FlxSpriteGroup {
	public static var instance:Null<SaveEntry> = null;
	public var character:Null<AstheSprite> = null;

	public function new(id:Int) {
		super();
		instance = this;

		var data = ClientPrefs.loadSlotData(id);

		var portrait:AstheSprite;
		if (!ClientPrefs.slotExists(id)) {
			portrait = AstheSprite.create(2, 2, "menus/saveSelect/savePortrait_new");
			add(portrait);
		}

		var save:AstheSprite = AstheSprite.create(0, 0, "menus/saveSelect/save");
		add(save);

		//var label:AstheBitmapText =

		for (i in 0...7) {
			var colors:Array<String> = [
				"cyan", "red", "green", "yellow", "gray", "purple", "blue"
			];

			var emerald:AstheSprite = AstheSprite.createAdaptiveSpriteSheet(2, save.height - 12, "menus/saveSelect/emeralds");
			emerald.x += ((emerald.width / emerald.frameCount) * i) + i;

			emerald.animation.add(colors[i], [i], false, false);

			emerald.animation.play(colors[i]);

			emerald.visible = (ClientPrefs.slotExists(id)) ? (data?.emeralds[i] ?? false) : false;
			add(emerald);
		}

		character = AstheSprite.create(save.x + (save.width / 2), save.y + (save.height / 2), "menus/saveSelect/characters/" + SaveSelect.charList[0]);
		character.x -= (character.width / 2);
		add(character);
	}
}

/**
	The current state of the save slot
**/
enum SaveState {
	/**
		The save slot is in blank state or does not
		have a save file
	**/
	New;

	/**
		The save slot has a save file and is not blank;
	**/
	InProgress;

	/**
		The save slot is clear (the player finished the game on this slot)
	**/
	Clear;
}