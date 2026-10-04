
package asthe.options;

/** @see https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/options/Option.hx **/
class Option<T> {
	// { region Variables
	/** Returns the name of this option. **/
	public var name:String = "Unknown Option";
	/** Description of this option. **/
	public var desc:String = "This option does not have a description.";
	/** Translatable key of this option. **/
	public var flag:String = "";
	/** Save Variable key of this option. **/
	public var saveVar(default, null):Null<String>;
	/** Current value of this option. **/
	public var value(get, set):T;
	/**
		Set's a display format, how the option will look
		Placeholder values:

		`{0}`: Value of the option
		`{1}`: Default value
	**/
	public var display:String = "{0}";
	/** Default value of this option. **/
	public var defaultV:T;

	public var child:AstheText;
	public var text(get, set):Null<String>;
	// } end region

	/**
		Creates a new option
		@param flag Translatable key (Not the text!)
		@param saveVar Variable name to identify your option
		@param type Option type (`BOOL, STRING, NUMBER`)
		@param options Options per type, `BOOL` doesn't need that.
	**/
	inline public function new(flag:String = "", saveVar:String = "", defaultValue:T) {
		this.name = Locale.getString(flag, "options");
		this.desc = Locale.getString(flag + "_desc", "options");
		this.saveVar = saveVar;
		this.flag = flag;
		this.value = fetchValue() ?? defaultV;
	}

	public function toString():String {
		return "Option(name='{0}', desc='{1}', flag='{2}')".format(name, desc, flag);
	}

	/**
		Event that is triggered when the option changes
		@param step Change amount
	**/
	public function onChange(step:Float):Void {}

	/**
		The formatted value to return
		@return String
	**/
	public function formatValue():String {
		return Std.string(value);
	}

	private function fetchValue():Null<T>
		return Reflect.getProperty(ClientPrefs.data.options, saveVar);

	private function get_value():T
		return Reflect.getProperty(ClientPrefs.data.options, saveVar);

	private function set_value(value:T):T {
		Reflect.setProperty(ClientPrefs.data.options, saveVar, value);
		return value;
	}

	var _text:String = null;
	private function get_text() return _text;
	private function set_text(newValue:String = '') {
		if (child != null) {
			_text = newValue;
			child.text = !StringUtil.isBlank(flag) ? Locale.getString(flag + "-" + value, "options") : _text;
			return _text;
		}

		return null;
	}
}
