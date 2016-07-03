package hxsuite.benchmarks;

class Now {

	public static function get() {
		#if nodejs
		var hr = js.Node.process.hrtime();
		return hr[0] + hr[1] * 1.0E-9;
		#elseif js
		return js.Browser.window.performance.now() * 1.0E-3;
		#else
		return haxe.Timer.stamp();
		#end
	}
}
