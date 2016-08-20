package hxsuite.benchmarks;

import haxe.macro.Compiler;
import haxe.ds.StringMap;

@:autoBuild(hxsuite.benchmarks.BenchmarkBuilder.build())
class Benchmark {

	public var className:String;
	public var mute:Bool = false;
	public var baseIterations:Int = 1;
	public var runs:Int = 10;
	public var reports:StringMap<BenchmarkReport> = new StringMap();
	public var onCompleted:Void->Void;

	public function new() {
		className = Type.getClassName(Type.getClass(this));
	}

	public function run() {
		__warmupTests();
		__runTests();
		__complete();
	}

	function __complete() {
		for(report in reports) {
			report.timeAvg = report.time / report.runs;
		}
		if(onCompleted != null) {
			onCompleted();
		}
	}

	function __runTests() {
		throw "no tests";
	}

	function __warmupTests() {
		throw "no tests";
	}

	function report(method:String, timeSeconds:Float, ops:Int) {
		if(mute) {
			return;
		}
		var result = reports.get(method);
		if(result == null) {
			result = new BenchmarkReport();
			result.suite = className;
			result.method = method;
			trace("ops: " + ops);
			trace("runs: " + runs);
			trace("method: " + method);
			result.ops = ops;
			result.runs = runs;
			reports.set(method, result);
		}

		trace("time: " + timeSeconds);
		
		if(timeSeconds > result.timeMax) {
			result.timeMax = timeSeconds;
		}
		if(timeSeconds < result.timeMin) {
			result.timeMin = timeSeconds;
		}
		result.time += timeSeconds;
		onTestCompleted();
	}

	function onTestCompleted() {}



}
