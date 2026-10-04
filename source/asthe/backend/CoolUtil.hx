package asthe.backend;

class CoolUtil {
	/**
		Parses an String and convert it into a Bool
		@param k The value to parse (Allowed: "true/false", "0/1")
		@return Bool or Bool>false
		@author Sunnydev31 (unreal.sunnydev)
	**/
	public static function parseBool(k:String):Bool {
		return switch (k.toLowerCase()) {
			case "true" | "1": true;
			case "false" | "0": false;
			default: false;
		}
	}
}

