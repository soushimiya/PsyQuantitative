import objects.BGSprite;
import states.stages.objects.DadBattleFog;

var dadbattleBlack:BGSprite;
var dadbattleLight:BGSprite;
var dadbattleFog:DadBattleFog;

function onCreate()
{
	var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
	addBehindGF(bg);

	var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	stageFront.updateHitbox();
	addBehindGF(stageFront);
	if (!ClientPrefs.data.lowQuality)
	{
		var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
		stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
		stageLight.updateHitbox();
		addBehindGF(stageLight);
		var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
		stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
		stageLight.updateHitbox();
		stageLight.flipX = true;
		addBehindGF(stageLight);

		var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		add(stageCurtains);
	}
}

function onEventPushed(event:String)
{
	switch (event)
	{
		case "Dadbattle Spotlight":
			dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
			dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			dadbattleBlack.alpha = 0.25;
			dadbattleBlack.visible = false;
			addBehindGF(dadbattleBlack);

			dadbattleLight = new BGSprite('spotlight', 400, -400);
			dadbattleLight.alpha = 0.375;
			dadbattleLight.blend = addBehindGF;
			dadbattleLight.visible = false;
			addBehindDad(dadbattleLight);

			dadbattleFog = new DadBattleFog();
			dadbattleFog.visible = false;
			add(dadbattleFog);
	}
}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	var flValue1:Null<Float> = Std.parseFloat(value1);
	var flValue2:Null<Float> = Std.parseFloat(value2);
	
	switch (eventName)
	{
		case "Dadbattle Spotlight":
			if (flValue1 == null)
				flValue1 = 0;
			var val:Int = Math.round(flValue1);

			switch (val)
			{
				case 1, 2, 3: // enable and target dad
					if (val == 1) // enable
					{
						dadbattleBlack.visible = true;
						dadbattleLight.visible = true;
						dadbattleFog.visible = true;
						game.defaultCamZoom += 0.12;
					}

					var who:Character = dad;
					if (val > 2)
						who = boyfriend;
					// 2 only targets dad
					dadbattleLight.alpha = 0;
					new FlxTimer().start(0.12, function(tmr:FlxTimer)
					{
						dadbattleLight.alpha = 0.375;
					});
					dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);
					FlxTween.tween(dadbattleFog, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});

				default:
					dadbattleBlack.visible = false;
					dadbattleLight.visible = false;
					game.defaultCamZoom -= 0.12;
					FlxTween.tween(dadbattleFog, {alpha: 0}, 0.7, {onComplete: function(twn:FlxTween) dadbattleFog.visible = false});
			}
	}
}
