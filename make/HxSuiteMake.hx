using hxmake.haxelib.HaxelibPlugin;

class HxSuiteMake extends hxmake.Module {
	function new() {
		config.classPath = ["src"];
		config.devDependencies = [
			"hxnodejs" => "haxelib"
		];

		apply(hxmake.idea.IdeaPlugin);
		apply(hxmake.haxelib.HaxelibPlugin);

		library();
	}
}