package hxsuite.benchmarks;

class BenchmarkReport {

	public var suite:String;
	public var method:String;
	public var time:Float = 0;
	public var timeAvg:Float = 0;
	public var timeMin:Float = 1000000000;
	public var timeMax:Float = 0;
	public var ops:Float = 0;
	public var runs:Int;

	public function new() {}
}
