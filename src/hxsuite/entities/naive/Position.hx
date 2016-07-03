package hxsuite.entities.naive;

@:unreflective
class Position extends Component {

	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function randomize():Position {
		x = Math.random();
		y = Math.random();
		return this;
	}
}
