package hxsuite;

import haxe.Json;
import haxe.ds.StringMap;
import neko.Lib;
import neko.Web;

class Host {
	static var _cached:Bool = false;

	static var _currentOpt:String = null;
	static var _reports:Array<Report> = [];

	public static function main() {
		if (!_cached) {
			Web.cacheModule(main);
			_cached = true;
		}

		var params:StringMap<String> = Web.getParams();
		var cmd = params.get("cmd");
		if (cmd == "post") {
			var report = new Report();
			report.parse(params, _currentOpt);
			_reports.push(report);
			Lib.print("OK");
		}
		else if (cmd == "report") {
			printReport(_reports);
		}
		else if (cmd == "opt") {
			_currentOpt = params.get("opt");
		}
		else if (cmd == "status") {
			for(r in _reports) {
				if(r.target == params.get("target") && r.optVersion == params.get("opt")) {
					Lib.print("ready");
					Web.flush();
					return;
				}
			}
			Lib.print("running");
		}
		Web.flush();
	}

	static function printReport(reports:Array<Report>) {
		var byName:StringMap<Array<Report>> = new StringMap();
		var targets:Array<String> = [];
		for (r in reports) {
			var arr = byName.get(r.qname);
			if (arr == null) {
				arr = [];
				byName.set(r.qname, arr);
			}
			arr.push(r);
			if(targets.indexOf(r.targetTitle) < 0) {
				targets.push(r.targetTitle);
			}
		}

		targets.sort(sortStrings);
		//targets.unshift("Test");

		var targetsData:Array<Dynamic> = ["Test"];
		for(target in targets) {
			targetsData.push({label:target, type:'number'});
			targetsData.push({label:'min', role:'interval'});
			targetsData.push({label:'max', role:'interval'});
			targetsData.push({role:'annotation'});
		}

		var data:Array<Array<Dynamic>> = [targetsData];
		for(qname in byName.keys()) {
			var namedReports:Array<Report> = byName.get(qname);
			namedReports.sort(sortByTarget);
			var set:Array<Dynamic> = [qname.split(".").pop()];
			for(namedReport in namedReports) {
				set.push(namedReport.speed);
				set.push(namedReport.speedMin);
				set.push(namedReport.speedMax);
				set.push(namedReport.targetTitle);//namedReport.speedMax);
			}
			data.push(set);
		}

		var dsj = Json.stringify(data);
		var body = "";

		for(report in reports) {
			body += report.targetTitle + " : " + report.method + " : " + report.ops + " " + report.timeMin + " / " + report.timeMax + "<br/>";
		}

		var script = "google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable(" + dsj + ");

        var options = {
          title: 'Haxe Benchmarks',
          bars: 'horizontal',
          hAxis: { title:'Iterations per Second', format: 'short' },
          vAxis: { title:'Suite'}
        };

        var chart = new google.visualization.BarChart(document.getElementById('barchart_material'));
        chart.draw(data, options);
      }";

		var html = '<html><head><script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script><script type="text/javascript">$script</script></head><body><div id="barchart_material" style="width: 900px; height: 500px;"></div>$body</body><html>';
		Lib.println(html);
	}

	static function sortByTarget(r1:Report, r2:Report):Int {
		return Reflect.compare(r1.targetTitle, r2.targetTitle);
	}

	static function sortStrings(a:String, b:String):Int {
		return Reflect.compare(a, b);
	}
}

class Report {
	public var qname:String;
	public var suite:String;
	public var method:String;
	public var target:String;
	public var targetTitle:String;
	public var ops:Float;
	public var time:Float;
	public var timeMin:Float;
	public var timeMax:Float;
	public var speedMin:Float;
	public var speedMax:Float;
	public var speed:Float;
	public var optVersion:String;

	public function new() {}

	public function parse(params:StringMap<String>, opt:String) {
		suite = params.get("suite");
		method = params.get("method");
		target = params.get("target");
		ops = Std.parseFloat(params.get("ops"));
		time = Std.parseFloat(params.get("time"));
		timeMin = Std.parseFloat(params.get("min"));
		timeMax = Std.parseFloat(params.get("max"));

		targetTitle = target;
		if(opt != null) {
			targetTitle += "." + opt;
		}

		optVersion = opt;
		qname = suite + "." + method;
		speed = calcSpeed(time, ops);
		speedMax = calcSpeed(timeMin, ops);
		speedMin = calcSpeed(timeMax, ops);
	}

	static function calcSpeed(time:Float, iterations:Float):Float {
		return time >= 0.00001 ? Math.ffloor(iterations / time) : 0;
	}
}