package asthe.options.types;

import asthe.options.Option;

@:nullSafety
class StringOption extends Option<String> {
	/**
		Set's a list of values for this option.
	**/
	public var list:Array<String>;

	/**
	Creates a `String` option entry
		@param flag Translatable flag, used to display the name and description
		@param saveVar The save variatble to use
		@param defaultValue Default value of this option
		@param list List of options to use
	**/
	public function new(flag:String, saveVar:String, defaultValue:String = "No Options", list:Array<String>) {
		this.list = list ?? ["No Options"];
		super(flag, saveVar, defaultValue);
	}

	override function onChange(s:Float) {		
		var index:Int = list.indexOf(value);

		if (index == -1) index = 0;

		index = MathUtil.clamp(index + Std.int(s), 0, list.length - 1);
		value = list[index];
	}
}