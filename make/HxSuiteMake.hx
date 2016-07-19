using hxmake.haxelib.HaxelibPlugin;

class HxSuiteMake extends hxmake.Module {
	function new() {
		config.classPath = ["src"];
		config.devDependencies = [
			"hxnodejs" => "haxelib"
		];

		apply(hxmake.idea.IdeaPlugin);
		apply(hxmake.haxelib.HaxelibPlugin);

		var cfg = library().config;
		cfg.version = "0.0.1";
		cfg.description = "Cross-platform running tasks";
		cfg.url = "https://github.com/eliasku/hxsuite";
		cfg.tags = ["hxmake", "cross", "run", "benchmark", "tools"];
		cfg.contributors = ["eliasku"];
		cfg.license = "MIT";
	}
}