package hxsuite.entities.tools;
#if cpp
class CppCast {
	@:extern inline public static function unsafe<A, T>(obj:A):T {
		return cpp.Pointer.fromRaw(cpp.Pointer.addressOf(obj).rawCast()).value;
	}
}
#end
