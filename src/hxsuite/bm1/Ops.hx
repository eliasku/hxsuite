package hxsuite.bm1;

import haxe.Int32;
import hxsuite.benchmarks.Benchmark;

@:iterations(1000000)
@:runs(10)
class Ops extends Benchmark {

	var _result:Int = 0;

	public function new() {
		super();
	}

	@:test
	public function fibb() {
		var a:Int32 = 0 | 0;
		var b:Int32 = 1 | 0;
		var c:Int32 = 0 | 0;
		@body(10) {
			c = a + b;
			a = b;
			b = c;
		}

		if(a == 0) {
			throw "BAD";
		}
		_result = a;
	}
//
//	@:test
//	public function sub() {
//		var r1:Int = Std.int(Math.random()*2);
//		var r2:Int = Std.int(Math.random()*3);
//		var r:Int = 0;
//
//		@body(1) {
//			r = (r1 - r2) #if js | 0 #end;
//			r2 = r1;
//			r1 = r;
//		}
//
//		_result = r;
//	}
//
//	@:test
//	public function div() {
//		var r1:Int = 1;
//		var r2:Int = -1;
//		var r:Int = 0;
//
//		@body(10) {
//			r = NativeMath.idiv(r1, r2);
//			r2 = r1;
//			r1 = r;
//		}
//
//		_result = r;
//	}
//
//	@:test
//	public function mul() {
//		var r1:Int = 1;
//		var r2:Int = 2;
//		var r:Int = 0;
//
//		@body(10) {
//			r = (r1 * r2) #if js | 0 #end;
//			r1 = r2;
//			r2 = r;
//		}
//
//		_result = r;
//	}

	override function onTestCompleted() {
		trace(_result);
	}

}
