package objects;

import flxAnimate.FlxAnimate;

class FreeplayDJ extends FlxAnimate
{
	public function new(x:Float, y:Float, id:String) {
		super(x, y, Paths.getPath("images/freeplay/freeplay-boyfriend"));
	}
}