package substates;

import flixel.FlxSprite;
import objects.*;

class FreeplaySubState extends MusicBeatSubstate
{
	public static var fromMainMenu:Bool = true;
	
	override public function new(?fromMainMenu:Bool = false)
	{
		super();
		FreeplaySubState.fromMainMenu = fromMainMenu;
	}

	override function create()
	{
		var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
		fnfFreeplay.font = 'VCR OSD Mono';
		fnfFreeplay.visible = false;
	}
}
