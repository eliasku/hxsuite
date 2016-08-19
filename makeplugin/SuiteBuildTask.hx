import hxmake.utils.Haxelib;
import hxmake.cli.CL;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxe.Template;
import sys.io.Process;
import hxmake.Task;

typedef RunTarget = {
	var target:String;
	@:optional var opt:String;
}

class SuiteBuildTask extends Task {

	public inline static var SERVE_START_WAIT_MS:Int = 1000;
	public inline static var TARGET_PING_INVERVAL_MS:Int = 1000;
	public inline static var DOMAIN:String = "localhost";
	public inline static var PORT:Int = 2001;

	public var main:String;
	public var classPath:Array<String> = [];
	public var libraries:Array<String> = [];

	public var defaultTargets:Array<String> = ["swf", "cpp", "node", "js", "cs", "java"];
	public var defaultApps:Array<String> = [];

	var _mainClass:String;

	var _apps:Array<String> = [];
	var _appIndex:Int = 0;
	var _currentApp:String;

	var _targets:Array<RunTarget> = [];
	var _hostProcess:Process;

	public function new() {

	}

	override public function run() {

		CL.workingDir.push(module.path);

		var typePath = main.split(".");
		_mainClass = typePath[typePath.length - 1];

//		var toIgnore = ["lua", "python", "hl"];
//		var runTargets:Array<RunTarget> = [
//			{target: "cpp"},
//			{target: "js"},
//				//{target: "js", opt: "min"},
//				//{target: "js", opt: "yui"},
//			{target: "node"},
//				//{target: "node", opt: "min"},
//				//{target: "node", opt: "yui"},
//			{target: "swf"},
//			{target: "java"},
//			{target: "cs"},
//			{target: "neko"}
//			//{target: "python"}
//		];// "hl", "lua"];

		for (arg in module.project.args) {
			if (arg.indexOf("-target=") == 0) {
				var targets = arg.substr("-target=".length).split(",");
				for(targetId in targets) {
					_targets.push({target: targetId});
				}
			}
			if (arg.indexOf("-app=") == 0) {
				var apps = arg.substr("-app=".length).split(",");
				_apps = _apps.concat(apps);
			}
		}

		if (_apps.length == 0) {
			for(app in defaultApps) {
				_apps.push(app);
			}
		}

		if (_targets.length == 0) {
			for(targetId in defaultTargets) {
				_targets.push({ target: targetId });
			}
		}

		if (Sys.command("haxe", [
			"-cp", Path.join([Haxelib.libPath("hxsuite"), "src"]),
			"-main", "hxsuite.Host",
			"-neko", "host/index.n"]) != 0) {

			fail("Compile error");
		}

		_hostProcess = new Process("nekotools", ["server", "-p", Std.string(PORT), "-h", DOMAIN, "-d", "host/"]);
		Sys.sleep(SERVE_START_WAIT_MS / 1000);
		try {
			Sys.println(_hostProcess.stdout.readLine());
		}
		catch (e:Dynamic) {}

		CL.workingDir.pop();

		nextApp();
	}

	function nextApp() {
		if (_appIndex < _apps.length) {
			_currentApp = _apps[_appIndex];
		}
		else {
			openUrl(getUrl(["cmd" => "report"]), true);
			Sys.sleep(SERVE_START_WAIT_MS / 1000);
			Sys.println("Press any key to continue...");
			while(true) {
				Sys.sleep(0.5);
				var i = Sys.getChar(false);
				Sys.println(i);
				Sys.println("WIN");
				if(i != 0) {
					break;
				}
			}
			Sys.println("END");
			complete();
			Sys.println("RETURN");
			return;
		}

		CL.workingDir.push(module.path);

		for (t in _targets) {
			build(t.target, t.opt);
		}

		for (t in _targets) {
			optimize(t.target, t.opt);
		}

		if (module.project.args.indexOf("-build") < 0) {
			runTests(_targets.copy(), function() {
				++_appIndex;
				nextApp();
			});
		}

		CL.workingDir.pop();
	}

	function runTests(targets:Array<RunTarget>, onComplete:Void -> Void) {
		if (targets.length == 0) {
			onComplete();
			return;
		}
		startTest(targets.pop(), function() {
			runTests(targets, onComplete);
		});
	}

	function getCommonBuildOptions(target:String):Array<String> {
		var args = [];
		for (cp in module.config.classPath.concat(classPath)) {
			args.push("-cp");
			args.push(cp);
		}

		args.push("-main");
		args.push(main);

		args.push("-D");
		args.push("target=" + target);

		args.push("-D");
		args.push("app=" + _currentApp);

		for (lib in libraries.concat(["hxsuite"])) {
			args.push("-lib");
			args.push(lib);
		}

		return args;
	}

	function build(target:String, opt:String) {
		var args = getCommonBuildOptions(target);
		switch(target) {
			case "cpp":
				args.push("-D");
				args.push("no_debug");
				//args.push("--no-traces");
				args.push("-cpp");
				args.push('build/$_currentApp-cpp');
//			case "hl":
//				args.push("-hl");
//				args.push("build/hl.c");
			case "neko":
				args.push("-neko");
				args.push('build/$_currentApp.n');
			case "node":
				args.push("-lib");
				args.push("hxnodejs");
				args.push("-js");
				args.push('build/$_currentApp-node.js');
			case "js":
				args.push("-js");
				args.push('build/$_currentApp.js');
			case "swf":
				args.push("-D");
				args.push("network-sandbox");
				args.push("-swf");
				args.push('build/$_currentApp.swf');
			case "python":
				args.push("-python");
				args.push('build/$_currentApp.py');
			case "lua":
				args.push("-D");
				args.push("lua-jit");
				args.push("-lua");
				args.push('build/$_currentApp.lua');
			case "java":
				args.push("-java");
				args.push('build/$_currentApp-java');
			case "cs":
				args.push("-cs");
				args.push('build/$_currentApp-cs');
			case "php":
				args.push("-php");
				args.push('build/$_currentApp-php');
			case "interp":
				// skip
				return;
			default:
				throw "Unknown target '" + target + "'";
		}

		Sys.println('> haxe ${args.join(" ")}');
		if (Sys.command("haxe", args) != 0) {
			throw "Build failed";
		}
	}

	function optimize(target:String, opt:String) {
		if (opt != null) {
			if (target == "js") {
				minify('build/$_currentApp.js', opt, true);
			}
			else if (target == "node") {
				minify('build/$_currentApp-node.js', opt, false);
			}
		}
	}

	function startTest(runTarget:RunTarget, onComplete:Void -> Void) {
		var async = false;
		var cmd = null;
		var args = [];
		var url = null;
		var mainPath = main.split(".");
		var mainName = mainPath[mainPath.length - 1];
		switch(runTarget.target) {
			case "cpp":
				cmd = './build/$_currentApp-cpp/' + _mainClass;
//			case "hl":
//				cmd = "gcc";
//				args = ["./build/hl.c"];
			case "neko":
				cmd = "neko";
				args = ['build/$_currentApp.n'];
			case "node":
				cmd = "node";
				var file = runTarget.opt != null ?
					('$_currentApp-node.' + runTarget.opt + ".js") :'$_currentApp-node.js';
				args = ['build/$file'];
			case "js":
				url = hostBuild("js", runTarget.opt, runTarget.opt != null ? ('$_currentApp.' + runTarget.opt + ".js") : '$_currentApp.js');
				async = true;
			case "swf":
				url = hostBuild("flash", null, '$_currentApp.swf');
				async = true;
			case "python":
				cmd = "python3";
				args = ['build/$_currentApp.py'];
			case "lua":
				cmd = "lua";
				args = ['build/$_currentApp.lua'];
			case "java":
				cmd = javaBin;
				args = ["-jar", 'build/$_currentApp-java/$mainName.jar'];
			case "cs":
				if(CL.platform.isWindows) {
					cmd = StringTools.replace('build/$_currentApp-cs/bin/$mainName.exe', "/", "\\");
				}
				else {
					cmd = "mono";
					args = ["-O=all", 'build/$_currentApp-cs/bin/$mainName.exe'];
				}
			case "php":
				cmd = "php";
				args = ['build/$_currentApp-php/index.php'];
			case "interp":
				cmd = "haxe";
				args = getCommonBuildOptions(runTarget.target);
				args.push("--interp");
			default:
				throw "Unknown target '" + runTarget.target + "'";
		}

		postOpt(runTarget.opt, function() {
			if(url != null) {
				openUrl(url);
			}
			else {
				Sys.command(cmd, args);
			}

			if (async) {
				waitTarget(runTarget.target, _currentApp, runTarget.opt, onComplete);
			}
			else {
				onComplete();
			}
		});
	}

	function hostBuild(target:String, ckind:String, bin:String):String {
		var tplName = 'browse-$target';
		var hostedName = ckind != null ? '$tplName-$ckind.html' : '$tplName.html';
		var mpp = Haxelib.libPath("hxsuite");
		var tpl = new Template(File.getContent(Path.join([mpp, 'makeplugin/$tplName.html'])));

		if (!FileSystem.exists("host")) {
			FileSystem.createDirectory("host");
		}
		File.saveContent("host/" + hostedName, tpl.execute({BIN_PATH:bin}));
		File.copy("build/" + bin, "host/" + bin);
		return 'http://${getHostName()}/$hostedName';
	}

	function waitTarget(target:String, app:String, opt:String, onComplete:Void -> Void) {
		Sys.println("WAITING " + target);
		var url = getUrl([
			"cmd" => "status",
			"opt" => opt,
			"app" => app,
			"target" => target
		]);
		var http = new haxe.Http(url);
		http.onData = function(data:String) {
			if (data == "ready") {
				onComplete();
			}
			else {
				Sys.sleep(TARGET_PING_INVERVAL_MS / 1000);
				waitTarget(target, _currentApp, opt, onComplete);
			}
		}
		http.onError = function(msg:String) {
			Sys.println("HTTP ERROR: " + msg);
		}
		http.request(false);
	}

	static function postOpt(opt:String, onComplete:Void -> Void) {
		var url = getUrl([
			"cmd" => "opt",
			"opt" => opt
		]);
		var http = new haxe.Http(url);
		http.onData = function(data:String) {
			onComplete();
		}
		http.onError = function(msg:String) {
			Sys.println("url: " + url);
			Sys.println("postOpt ERROR: " + msg);
		}
		http.request(false);
	}

	function complete() {
		// complete
		if(_hostProcess != null) {
			_hostProcess.kill();
			_hostProcess = null;
		}
	}

	static function minify(input:String, opt:String, agressive:Bool) {
		var output:String = Path.withExtension(input, opt + ".js");

		if (opt == "yui") {
			if (!yui(input, output)) {
				Sys.println("ERROR: yui failed");
			}
		}
		else if (opt == "min") {
			if (!compjs(input, output, agressive)) {
				Sys.println("ERROR: compiler js failed");
			}
		}
	}

	//static var javaBin = "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java";
	static var javaBin = "java";

	static function yui(input:String, output:String):Bool {
		if (!FileSystem.exists(input)) {
			return false;
		}
		Sys.println("yui compression...");
		var yuiPath = Path.join([Haxelib.libPath("hxmake"), "resources", "yuicompressor-2.4.7.jar"]);
		var result = CL.execute(javaBin, ["-Dapple.awt.UIElement=true", "-jar", yuiPath, "-o", output, input]);
		if (result.exitCode != 0) {
			Sys.println(result.stderr);
			Sys.println(result.stdout);
			return false;
		}
		return true;
	}

	static function compjs(input:String, output:String, aggressive:Bool):Bool {
		if (!FileSystem.exists(input)) {
			return false;
		}
		Sys.println("js-compiler compression...");
		var compilerPath = Path.join([Haxelib.libPath("hxmake"), "resources", "compiler.jar"]);
		var args = ["-Dapple.awt.UIElement=true", "-jar", compilerPath, "--js", input, "--js_output_file", output];
		//if (!LogHelper.verbose) {
		//args.push("--jscomp_off=uselessCode");
		args.push("--compilation_level");
		//args.push(aggressive ? "ADVANCED_OPTIMIZATIONS" : "WHITESPACE_ONLY");//"SIMPLE_OPTIMIZATIONS");
		args.push("WHITESPACE_ONLY");
		//}
		var result = CL.execute(javaBin, args);
		if (result.exitCode != 0) {
			Sys.println(result.stderr);
			Sys.println(result.stdout);
			return false;
		}
		return true;
	}

	static function getHostName():String {
		return DOMAIN + ":" + PORT;
	}


	static function getVariables(map:Map<String, String>):String {
		var vars = [];
		for(key in map.keys()) {
			var value = map.get(key);
			if(value != null) {
				vars.push('$key=$value');
			}
		}
		return vars.length > 0 ? ("?" + vars.join("&")) : "";
	}

	static function getUrl(vars:Map<String, String>):String {
		return 'http://${getHostName()}/' + getVariables(vars);
	}

	static function openUrl(url:String, focus:Bool = false) {
		if(CL.platform.isWindows) {
			Sys.command("cmd /c start " + url);
		}
		else {
			var args = [url];
			if(!focus) {
				args.unshift("-g");
			}
			Sys.command("open", args);
		}
	}
}