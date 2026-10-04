package util;

@:nullSafety
class MathUtil {
	/**
		Bounds a number `value` into their `max` and `min` values

		If `value` is greater than `max` -> returns `max`
		If `value` is less than `min` -> returns `min`
		Otherwise, returns `value`
		@param value The value to bound
		@param min Minimum value allowed
		@param max Maximum value allowed
		@returns T (Float/Int)
	**/
	inline public static function clamp<T:Float>(value:T, min:T, max:T):T {
		return cast Math.max(min, Math.min(value, max));
	}
}
