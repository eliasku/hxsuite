package hxsuite.benchmarks;

import haxe.macro.Expr.ExprDef;
import haxe.macro.Type.ClassType;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.Field;
import haxe.macro.Context;
import haxe.macro.Expr;

@:final
class BenchmarkBuilder {
	public static function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();
		var testFields:Array<TestFieldInfo> = [];

		var globalIterations:Int = cls.meta.has(":iterations") ?
			getMetaInt(cls.meta.extract(":iterations")[0], 0, 1) : 1;

		var globalRuns:Int = cls.meta.has(":runs") ?
			getMetaInt(cls.meta.extract(":runs")[0], 0, 1) : 10;

		for(field in fields) {
			field.meta.push({name:":keep", pos:Context.currentPos()});
			var iterations:Int = globalIterations;
			var isTest:Bool = false;
			for(meta in field.meta) {
				switch(meta.name) {
					case ":test": isTest = true;
					case ":iterations":
						iterations = getMetaInt(meta, 0, 1);
				}
			}
			if(isTest) {
				var testField = {
					name: field.name,
					iterations: iterations
				};
				testFields.push(testField);
				transform(field, testField.iterations);
			}
		}

		var calls:Array<Expr> = [];
		for(testField in testFields) {
			calls.push(macro {
				for(i in 0...runs) {
					$i{testField.name}();
				}
			});
		}

		var func:Function = {
			args: [],
			ret: null,
			expr: macro {
				baseIterations = $v{globalIterations} + Std.int(Math.random()*10);
				runs = $v{globalRuns} + Std.int(Math.random());
				mute = false;
				$b{calls}
			}
		};

		var runField = {
			name: "__runTests",
			access: [AOverride],
			kind: FFun(func),
			pos: Context.currentPos()
		};

		fields.push(runField);

		func = {
			args: [],
			ret: null,
			expr: macro {
				baseIterations = 1 + Std.int(Math.random());
				runs = 1;
				mute = true;
				$b{calls}
			}
		};

		var warmupField = {
			name: "__warmupTests",
			access: [AOverride],
			kind: FFun(func),
			pos: Context.currentPos()
		};

		fields.push(warmupField);
		return fields;
	}

	static function transform(field:Field, iterations:Int) {
		switch(field.kind) {
			case FFun(func):
				switch(func.expr.expr) {
					case EBlock(exprs):
						var totalOps:Float = 0;
						var index:Int = 0;
						var startIndex:Int = 0;
						var endIndex:Int = exprs.length;
						for(expr in exprs) {
							switch(expr.expr) {
								case ExprDef.EMeta(s, e):
									if(s.name == "body") {
										var repeat = getMetaInt(s, 0, 1);
										var loop = e;
										totalOps += iterations * repeat;
										if(repeat > 1) {
											var loopExprs:Array<Expr> = getBlockExprs(loop);
											var b = [];
											for(i in 0...repeat) {
												for(loopExpr in loopExprs) {
													b.push(loopExpr);
												}
											}
											loop = {expr: ExprDef.EBlock(b), pos: e.pos};
										}
										startIndex = index;
										expr.expr = EMeta(s,
											macro for(__current_iteration_index__ in 0...__iterations) ${loop}
											);
										endIndex = index + 1;
									}
								default:
							}
							++index;
						}

						if(totalOps == 0) {
							totalOps = 1;
						}

						var ps = macro {
							var __iterations:Int = baseIterations;
							var __hxsuite_time:Float = hxsuite.benchmarks.Now.get();
							__hxsuite_time = hxsuite.benchmarks.Now.get() - __hxsuite_time;
							report($v{field.name}, __hxsuite_time, $v{totalOps});
						};

						switch(ps.expr) {
							case EBlock(es):
								exprs.insert(startIndex, es[0]);
								exprs.insert(startIndex + 1, es[1]);
								exprs.insert(endIndex + 2, es[2]);
								exprs.insert(endIndex + 3, es[3]);
							default:
						}
					default:
						throw "use block expr in test function";
				}
			default:
				throw "bad function";
		}
	}

	static function getMetaInt(s:MetadataEntry, index:Int, defaultValue:Int = 0):Int {
		if(s.params.length > index) {
			switch(s.params[index].expr) {
				case ExprDef.EConst(CInt(value)):
					return Std.parseInt(value);
				default:
					throw "meta bad argument";
			}
		}
		return defaultValue;
	}

	static function getBlockExprs(block:Expr):Array<Expr> {
		switch(block.expr) {
			case ExprDef.EBlock(array):
				return array;
			default:
				throw "not a block";
		}
	}
}

typedef TestFieldInfo = {
	var name:String;
	var iterations:Int;
}