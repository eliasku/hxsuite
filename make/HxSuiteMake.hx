class HxSuiteMake extends hxmake.Module {
	function new() {
		config.classPath = ["src"];
		config.dependencies = [
			"hxnodejs" => "",
			"jazz" => "",
			"ecx" => ""
		];
		apply(hxmake.idea.IdeaPlugin);
		apply(hxmake.haxelib.HaxelibPlugin);

		var suiteTask = new SuiteBuildTask();
		suiteTask.libraries.push("ecx");
		suiteTask.libraries.push("jazz");
		task("suite", suiteTask);
	}
}