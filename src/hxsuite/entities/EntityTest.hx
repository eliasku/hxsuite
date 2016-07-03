package hxsuite.entities;

import hxsuite.entities.tools.CppCast;
import haxe.ds.IntMap;
import hxsuite.benchmarks.Benchmark;

import hxsuite.entities.naive.Entity in NaiveEntity;
import hxsuite.entities.naive.Position in NaivePosition;

@:iterations(100)
@:runs(10)
class EntityTest extends Benchmark {

	var _result:Float = 0;

	public function new() {
		super();
	}

	@:test
	public function naive() {
		var entities:Array<NaiveEntity> = [];
		for(i in 0...1000) {
			var e = new NaiveEntity();
			e.set(15, new NaivePosition().randomize());
			e.set(31, new NaivePosition().randomize());
			e.set(48, new NaivePosition().randomize());
			e.set(52, new NaivePosition().randomize());
			entities.push(e);
		}

		var result:Float = 0;
		@body {
			for(i in 0...entities.length) {
				var e:NaiveEntity = entities[i];
				var c:NaivePosition = e.get(15, NaivePosition);
				if(c != null) {
					result += c.x + c.y;
				}
				c = e.get(31, NaivePosition);
				if(c != null) {
					result += c.x + c.y;
				}
				c = e.get(48, NaivePosition);
				if(c != null) {
					result += c.x + c.y;
				}
				c = e.get(52, NaivePosition);
				if(c != null) {
					result += c.x + c.y;
				}
				c = e.get(58, NaivePosition);
				if(c != null) {
					result += c.x + c.y;
				}
			}
		}

		if(result < 0) {
			throw "BAD";
		}
		_result = result;
	}

	@:test
	public function naive_noCast() {
		var entities:Array<EntityBagNoCast> = [];
		for(i in 0...1000) {
			var e = new EntityBagNoCast();
			e.set(15, new PairNoCast());
			e.set(31, new PairNoCast());
			e.set(48, new PairNoCast());
			e.set(52, new PairNoCast());
			entities.push(e);
		}

		var result:Float = 0;
		@body {
			for(i in 0...entities.length) {
				var e:EntityBagNoCast = entities[i];
				var c:PairNoCast = e.get(15);
				if(c != null) {
					result += c.a + c.b;
				}
				c = e.get(31);
				if(c != null) {
					result += c.a + c.b;
				}
				c = e.get(48);
				if(c != null) {
					result += c.a + c.b;
				}
				c = e.get(52);
				if(c != null) {
					result += c.a + c.b;
				}
				c = e.get(58);
				if(c != null) {
					result += c.a + c.b;
				}
			}
		}

		if(result < 0) {
			throw "BAD";
		}
		_result = result;
	}

	@:test
	public function db_view() {
		var db:EntityDB = new EntityDB();
		var entities:Array<EntityIndex> = [];
		for(i in 0...1000) {
			var e = new EntityIndex(db);
			e.set(15, new Pair());
			e.set(31, new Pair());
			e.set(48, new Pair());
			e.set(52, new Pair());
			entities.push(e);
		}

		var result:Float = 0;
		@body {
			var view1:View<Pair> = db.view(15, Pair);
			var view2:View<Pair> = db.view(31, Pair);
			var view3:View<Pair> = db.view(48, Pair);
			var view4:View<Pair> = db.view(52, Pair);
			var view5:View<Pair> = db.view(58, Pair);
			for(i in 0...entities.length) {
				var e:EntityIndex = entities[i];
				var c = view1.get(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view2.get(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view3.get(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view4.get(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view5.get(e);
				if(c != null) {
					result += c.a + c.b;
				}
			}
		}

		if(result < 0) {
			throw "BAD";
		}
		_result = result;
	}

	@:test
	public function db_view_id() {
		var db:EntityDB = new EntityDB();
		var entities:Array<EntityId> = [];
		for(i in 0...1000) {
			var e = new EntityId(db);
			e.set(db, 15, new Pair());
			e.set(db, 31, new Pair());
			e.set(db, 48, new Pair());
			e.set(db, 52, new Pair());
			entities.push(e);
		}

		var result:Float = 0;
		@body {
			var view1:View<Pair> = db.view(15, Pair);
			var view2:View<Pair> = db.view(31, Pair);
			var view3:View<Pair> = db.view(48, Pair);
			var view4:View<Pair> = db.view(52, Pair);
			var view5:View<Pair> = db.view(58, Pair);
			for(i in 0...entities.length) {
				var e:EntityId = entities[i];
				var c = view1.getFast(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view2.getFast(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view3.getFast(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view4.getFast(e);
				if(c != null) {
					result += c.a + c.b;
				}
				c = view5.getFast(e);
				if(c != null) {
					result += c.a + c.b;
				}
			}
		}

		if(result < 0) {
			throw "BAD";
		}
		_result = result;
	}

	override function onTestCompleted() {
		trace(_result);
	}
}

@:generic
class Component {
	public var entity:Dynamic;
}

class Pair extends Component {

	public var a:Float;
	public var b:Float;

	inline public function new() {
		a = Math.random();
		b = Math.random() + a;
	}

}

/**

1. DB
2. UnsafeCast
3. Accessor

**/
class EntityIndex {

	public var id:Int = 0;
	public var db:EntityDB;

	inline public function new(db:EntityDB) {
		this.db = db;
		id = db.nextId++;
	}

	inline public function get<T:Component>(type:Int, cls:Class<T>):T {
		return db.get(id, type, cls);
	}

	inline public function set(type:Int, c:Component) {
		db.set(id, type, c);
	}
}

abstract EntityId(Int) from Int to Int {

	inline public function new(db:EntityDB) {
		this = db.nextId++;
	}

	inline public function get<T:Component>(db:EntityDB, type:Int, cls:Class<T>):T {
		return db.get(this, type, cls);
	}

	inline public function set(db:EntityDB, type:Int, c:Component) {
		db.set(this, type, c);
	}
}

class EntityDB {
	public var components:Array<Array<Component>> = [];
	public var nextId:Int = 0;

	public function new() {}
	public function set(id:Int, type:Int, data:Component) {
		var s = components[type];
		if(s == null) {
			s = [];
			components[type] = s;
		}
		s[id] = data;
		data.entity = id;
	}

	inline public function get<T:Component>(id:Int, type:Int, cls:Class<T>):T {
		var s = components[type];
		#if cpp
		return s != null ? CppCast.unsafe(s[id]) : null;
		#else
		return s != null ? (cast s[id]) : null;
		#end
	}

	@:generic
	public function view<T:Component>(type:Int, cls:Class<T>):View<T> {
		var s = components[type];
		if(s == null) {
			s = [];
			components[type] = s;
		}
		return new View<T>(s);
	}

}

@:generic
abstract View<T>(Array<T>) {

	inline public function new(arr:Array<Component>) {
		this = cast arr;
	}

	@:op([])
	inline public function get(entity:EntityIndex):T {
		return this[entity.id];
	}

	inline public function getFast(entity:EntityId):T {
		return this[entity];
	}
}


/*** NAIVE NO CAST ***/
class PairNoCast {

	public var a:Float;
	public var b:Float;
	public var entity:EntityBagNoCast;

	inline public function new() {
		a = Math.random();
		b = Math.random() + a;
	}

}

class EntityBagNoCast {

	public var components:Array<PairNoCast> = [];

	inline public function new() {}

	inline public function get(id:Int):PairNoCast {
		return components[id];
	}

	inline public function set(id:Int, c:PairNoCast) {
		components[id] = c;
		c.entity = this;
	}
}