package hxsuite.benchmarks;

import haxe.ds.StringMap;

@:autoBuild(hxsuite.benchmarks.BenchmarkBuilder.build())
class Benchmark {

	public var className:String;
	public var mute:Bool = false;
	public var baseIterations:Int = 1;
	public var runs:Int = 10;
	public var reports:StringMap<BenchmarkReport> = new StringMap();

	public function new() {
		className = Type.getClassName(Type.getClass(this));
	}

	public function run() {
		__warmupTests();
		__runTests();
		for(report in reports) {
			report.timeAvg = report.time / report.runs;
		}
	}

	function __runTests() {
		throw "no tests";
	}

	function __warmupTests() {
		throw "no tests";
	}

	function report(name:String, timeSeconds:Float, ops:Int) {
		if(mute) {
			return;
		}
		var result = reports.get(name);
		if(result == null) {
			result = new BenchmarkReport();
			result.suite = className;
			result.method = name;
			result.ops = ops;
			result.runs = runs;
			reports.set(name, result);
		}

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
