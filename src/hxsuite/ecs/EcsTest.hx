package hxsuite.ecs;

import ecx.MapTo;
import hxsuite.benchmarks.Benchmark;
import ecx.Engine in Ecx;

@:iterations(1000)
@:runs(1)
class EcsTest extends Benchmark {

	var _ecx:ecx.World;
	var _jazz:jazz.World;

	var _result:Float = 0;

	var _pos1:MapTo<EcxPosition>;
	var _pos2:MapTo<EcxPosition2>;
	var _pos3:MapTo<EcxPosition3>;
	var _pos4:MapTo<EcxPosition4>;

	public function new() {
		super();

		_ecx = Ecx.create(new ecx.WorldConfig([]));
		_jazz = new jazz.World(new jazz.WorldConfig([]));
		_pos1 = _ecx.database.mapTo(EcxPosition);
		_pos2 = _ecx.database.mapTo(EcxPosition2);
		_pos3 = _ecx.database.mapTo(EcxPosition3);
		_pos4 = _ecx.database.mapTo(EcxPosition4);
	}

	@:test
	public function jazz() {
		var entities:Array<jazz.Entity> = [];
		for(i in 0...1000) {
			var e = _jazz.create();
			e.create(JazzPosition).randomize();
			e.create(JazzPosition3).randomize();
			e.create(JazzPosition4).randomize();
			entities.push(e);
		}
		_jazz.invalidate();
		var result:Float = 0;
		@body {
			for(i in 0...entities.length) {
				var e:jazz.Entity = entities[i];
				var c:JazzPosition = e.get(JazzPosition);
				if(c != null) {
					result += c.x + c.y;
				}
				var c2:JazzPosition2 = e.get(JazzPosition2);
				if(c2 != null) {
					result += c2.x + c2.y;
				}
				var c3:JazzPosition3 = e.get(JazzPosition3);
				if(c3 != null) {
					result += c3.x + c3.y;
				}
				var c4:JazzPosition4 = e.get(JazzPosition4);
				if(c4 != null) {
					result += c4.x + c4.y;
				}
			}
		}

		for(i in 0...entities.length) {
			var e:jazz.Entity = entities[i];
			_jazz.delete(e);
		}

		_jazz.invalidate();
		trace("EC: " + @:privateAccess _jazz._entities.length);
		if(result < 0) {
			throw "BAD";
		}
		_result = result;
	}

	@:test
	public function ecx() {
		var entities:Array<ecx.Entity> = [];
		for(i in 0...1000) {
			var e = _ecx.create();
			e.create(EcxPosition).randomize();
			e.create(EcxPosition3).randomize();
			e.create(EcxPosition4).randomize();
			entities.push(e);
		}
		_ecx.invalidate();
		var result:Float = 0;
		@body {
			for(i in 0...entities.length) {
				var e:ecx.Entity = entities[i];
				var c:EcxPosition = e.get(EcxPosition);
				if(c != null) {
					result += c.x + c.y;
				}
				var c2:EcxPosition2 = e.get(EcxPosition2);
				if(c2 != null) {
					result += c2.x + c2.y;
				}
				var c3:EcxPosition3 = e.get(EcxPosition3);
				if(c3 != null) {
					result += c3.x + c3.y;
				}
				var c4:EcxPosition4 = e.get(EcxPosition4);
				if(c4 != null) {
					result += c4.x + c4.y;
				}
			}
		}

		for(i in 0...entities.length) {
			var e:ecx.Entity = entities[i];
			_ecx.delete(e);
		}

		_ecx.invalidate();

		trace("EC: " + @:privateAccess _ecx._entities.length);
		if(result < 0) {

			throw "BAD";
		}
		_result = result;
	}

	@:test
	public function ecx_map_fast() {
		var entities:Array<Int> = [];
		for(i in 0...1000) {
			var e = _ecx.create();
			e.create(EcxPosition).randomize();
			e.create(EcxPosition3).randomize();
			e.create(EcxPosition4).randomize();
			entities.push(e.id);
		}
		_ecx.invalidate();

		var pos1:MapTo<EcxPosition> = _ecx.database.mapTo(EcxPosition);
		var pos2:MapTo<EcxPosition2> = _ecx.database.mapTo(EcxPosition2);
		var pos3:MapTo<EcxPosition3> = _ecx.database.mapTo(EcxPosition3);
		var pos4:MapTo<EcxPosition4> = _ecx.database.mapTo(EcxPosition4);
		var result:Float = 0;
		@body {
			for(i in 0...entities.length) {
				var e:Int = entities[i];
				var c = pos1.getFast(e);
				if(c != null) {
					result += c.x + c.y;
				}
				var c2 = pos2.getFast(e);
				if(c2 != null) {
					result += c2.x + c2.y;
				}
				var c3 = pos3.getFast(e);
				if(c3 != null) {
					result += c3.x + c3.y;
				}
				var c4 = pos4.getFast(e);
				if(c4 != null) {
					result += c4.x + c4.y;
				}
			}
		}

		for(i in 0...entities.length) {
			var e:Int = entities[i];
			_ecx.delete(_ecx.database.entities[e]);
		}

		_ecx.invalidate();

		trace("EC: " + @:privateAccess _ecx._entities.length);
		if(result < 0) {

			throw "BAD";
		}
		_result = result;
	}

	@:test
	public function ecx_map_test() {
		var entities:Array<Int> = [];
		for(i in 0...1000) {
			var e = _ecx.create();
			e.create(EcxPosition).randomize();
			e.create(EcxPosition3).randomize();
			e.create(EcxPosition4).randomize();
			entities.push(e.id);
		}
		_ecx.invalidate();


		var result:Float = 0;
		@body {
			for(i in 0...entities.length) {
				var e:Int = entities[i];
				var c = _pos1.getFast(e);
				if(c != null) {
					result += c.x + c.y;
				}
				var c2 = _pos2.getFast(e);
				if(c2 != null) {
					result += c2.x + c2.y;
				}
				var c3 = _pos3.getFast(e);
				if(c3 != null) {
					result += c3.x + c3.y;
				}
				var c4 = _pos4.getFast(e);
				if(c4 != null) {
					result += c4.x + c4.y;
				}
			}
		}

		for(i in 0...entities.length) {
			var e:Int = entities[i];
			_ecx.delete(_ecx.database.entities[e]);
		}

		_ecx.invalidate();

		trace("EC: " + @:privateAccess _ecx._entities.length);
		if(result < 0) {

			throw "BAD";
		}
		_result = result;
	}

	override function onTestCompleted() {
		trace(_result);
	}
}

class JazzPosition extends jazz.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():JazzPosition {
		x = Math.random();
		y = Math.random();
		return this;
	}
}

class JazzPosition2 extends jazz.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():JazzPosition2 {
		x = Math.random();
		y = Math.random();
		return this;
	}
}

class JazzPosition3 extends jazz.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():JazzPosition3 {
		x = Math.random();
		y = Math.random();
		return this;
	}
}

class JazzPosition4 extends jazz.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():JazzPosition4 {
		x = Math.random();
		y = Math.random();
		return this;
	}
}

class EcxPosition extends ecx.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():EcxPosition {
		x = Math.random();
		y = Math.random();
		return this;
	}
}
class EcxPosition2 extends ecx.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():EcxPosition2 {
		x = Math.random();
		y = Math.random();
		return this;
	}
}
class EcxPosition3 extends ecx.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():EcxPosition3 {
		x = Math.random();
		y = Math.random();
		return this;
	}
}
class EcxPosition4 extends ecx.Component {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():EcxPosition4 {
		x = Math.random();
		y = Math.random();
		return this;
	}
}