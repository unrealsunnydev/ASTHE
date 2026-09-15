package util;

class ColorUtil {
	static final cssColors = [
		"maroom" => "800000",
		"black" => "FF000000",
		"silver" => "FFC0C0C0",
		"gray" => "FF808080",
		"grey" => "FF808080",
		"white" => "FFFFFFFF",
		"maroon" => "FF800000",
		"red" => "FFFF0000",
		"purple" => "FF800080",
		"fuchsia" => "FFFF00FF",
		"magenta" => "FFFF00FF",
		"green" => "FF008000",
		"lime" => "FF00FF00",
		"olive" => "FF808000",
		"yellow" => "FFFFFF00",
		"navy" => "FF000080",
		"blue" => "FF0000FF",
		"teal" => "FF008080",
		"aqua" => "FF00FFFF"
	];

	/**
		Converts a color into another!

		Supported inputs: `HEX`, `HEX Alpha`

		Example:
		```haxe
		ColorUtil.convert(0xFF0000, HEX);
		```

		@param fromColor The color format to convert;
		@param toColor The color format to return;
		@return Null<Dynamic>
	**/
	public static function convert(input:Dynamic, fromColor:ColorInput):Color {
		// I'll change it to bytes shifting later
		var from:Color = {r: "", g:"", b:""};
		trace('input="${input}"', 'fromColor="$fromColor"');

		switch (fromColor) {
			case HEX:
				var color:String = "";
				if (input is String) {
					trace("color is string");
					color = ~/0x|#/i.replace(input, "");
				}
				else if (input is Int) {
					trace("color is int");
					color = StringTools.hex(input, 6);
				}
				else
					throw new haxe.Exception("Cannot determine the type of 'color'");

				var hasAlpha:Bool = (color.length == 8);

				trace(color);
				from.r = color.substr(hasAlpha ? 2 : 0, 2);
				from.g = color.substr(hasAlpha ? 4 : 2, 2);
				from.b = color.substr(hasAlpha ? 6 : 4, 2);

				if (hasAlpha)
					from.a = color.substr(0, 2);

			case INT:
			case CSS:
				if (input is String) {
					if (input.contains("#") || input.contains("0x"))
						convert(input, HEX);
				}
				else
					throw new haxe.Exception("Invalid input type for option 'CSS'");
			case _:
		}
		return from;
	}

	/**
		Converts a color into a HEX color
		@param invertAlpha If true, the alpha channel
		is placed as the first parameter, else, is placed as the last one.
		@param bgr Returns if the color should use Blue Green Red format or not.
	**/
	public static function convertToHex(input:Dynamic, fromColor:ColorInput, ?invertAlpha:Bool = false, ?bgr:Bool = false):String {
		var color = convert(input, fromColor);

		var red = (!bgr) ? color.r : color.b;
		var green = color.g;
		var blue = (!bgr) ? color.b : color.r;
		var alpha = color.a ?? "";

		if (invertAlpha)
			return red + green + blue + alpha;

		return alpha + red + green + blue;
	}

	public static function convertToRGB(input:Dynamic, fromColor:ColorInput, ?invertAlpha:Bool = false, ?bgr:Bool = false):Array<Int> {
		var from = convert(input, fromColor);
		var color = [Std.parseInt(from.r), Std.parseInt(from.g), Std.parseInt(from.b)];
		if (!StringUtil.isBlank(from.a)) color.push(Std.parseInt(from.a));

		return color;
	}

	public static function convertToCSS(input:Dynamic, fromColor:ColorInput):String {
		var color = convert(input, fromColor);
		var fullColor = color.r + color.g + color.b;

		// hack: Use a MAP and iterate with their keys
		if (input is String) {
			if (cssColors.exists(input))
				return cssColors.get(input);

			for (i in cssColors) {
				if (input == i)
					return cssColors.get(i);
			}
		}
		return null;
	}
}

typedef Color = {
	/**
		Red color channel.
	**/
	var r:String;

	/**
		Green color channel.
	**/
	var g:String;

	/**
		Blue color channel.
	**/
	var b:String;

	/**
		Alpha color channel.
	**/
	@:optional var a:String;
}

enum ColorInput {
	/**
		Parses a hex color
	**/
	HEX;

	/**
		Parses a Int (RGB) color
	**/
	INT;

	/**
		Parses a CSS Named color
	**/
	CSS;
}