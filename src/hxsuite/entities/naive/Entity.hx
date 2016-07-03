package hxsuite.entities.naive;

import hxsuite.entities.tools.CppCast;

@:unreflective
class Entity {

	public var components(default, null):Array<Component> = [];

	public function new() {}

	inline public function get<T>(id:Int, cls:Class<T>):T {
		#if cpp
		return CppCast.unsafe(components[id]);
		#else
		return cast components[id];
		#end
	}

	inline public function set(id:Int, c:Component) {
		components[id] = c;
		c.entity = this;
	}
}
