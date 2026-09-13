package asthe.states.editor;

import asthe.objects.Character;
import asthe.objects.LifeIcon;

class CharacterEdt extends StateManager {
	var curCharacter:String = Constants.DEFAULT_CHARACTER;
	var character:Character;
	var liveIcon:LifeIcon;
	var camHUD:FlxCamera;
	
	public function new():Void {
		character = new Character(0, 0, curCharacter);
		liveIcon = new LifeIcon(curCharacter);
		super();
	}

	override public function create():Void {
		super.create();
	}

	override public function update(e:Float):Void {
		super.update(e);

		if (controls.BACK) {
			FlxG.switchState(() -> new asthe.states.MainMenu());
		}
	}
}