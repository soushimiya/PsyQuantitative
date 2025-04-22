var halloweenBG:BGSprite;
var halloweenWhite:BGSprite;

function onCreate()
{
	if (!ClientPrefs.data.lowQuality)
	{
		halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
	}
	else
	{
		halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
	}
	halloweenBG.scrollFactor.set(1, 1);
	addBehindGF(halloweenBG);

	// PRECACHE SOUNDS
	Paths.sound('thunder_1');
	Paths.sound('thunder_2');

	// Monster cutscene
	if (isStoryMode && !seenCutscene)
	{
		switch (songName)
		{
			case 'monster':
				PlayState.instance.startCallback = monsterCutscene;
		}
	}
}

function onCreatePost()
{
	halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
	halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
	halloweenWhite.alpha = 0;
	halloweenWhite.blend = ADD;
	add(halloweenWhite);
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function onBeatHit()
{
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
	{
		lightningStrikeShit();
	}
}

function lightningStrikeShit()
{
	FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	if (!ClientPrefs.data.lowQuality)
		halloweenBG.animation.play('halloweem bg lightning strike');

	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(8, 24);

	if (boyfriend.animOffsets.exists('scared'))
	{
		boyfriend.playAnim('scared', true);
	}

	if (dad.animOffsets.exists('scared'))
	{
		dad.playAnim('scared', true);
	}

	if (gf != null && gf.animOffsets.exists('scared'))
	{
		gf.playAnim('scared', true);
	}

	if (ClientPrefs.data.camZooms)
	{
		FlxG.camera.zoom += 0.015;
		game.camHUD.zoom += 0.03;

		if (!game.camZooming)
		{ // Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
			FlxTween.tween(game.camHUD, {zoom: 1}, 0.5);
		}
	}

	if (ClientPrefs.data.flashing)
	{
		halloweenWhite.alpha = 0.4;
		FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
		FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
	}
}

function monsterCutscene()
{
	inCutscene = true;
	game.camHUD.visible = false;

	FlxG.camera.focusOn(new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100));

	// character anims
	FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	if (gf != null)
		gf.playAnim('scared', true);
	boyfriend.playAnim('scared', true);

	// white flash
	var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
	whiteScreen.scrollFactor.set();
	whiteScreen.blend = ADD;
	add(whiteScreen);
	FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
		startDelay: 0.1,
		ease: FlxEase.linear,
		onComplete: function(twn:FlxTween)
		{
			remove(whiteScreen);
			whiteScreen.destroy();

			game.camHUD.visible = true;
			startCountdown();
		}
	});
}
