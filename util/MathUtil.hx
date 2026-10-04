package util;

@:nullSafety
class MathUtil {
	inline public static function clamp<T:Float>(value:T, min:T, max:T):T {
		return cast Math.max(min, Math.min(value, max));
	}
}