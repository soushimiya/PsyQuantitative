package converter;

import sys.FileSystem;
import sys.io.File;

using StringTools;

class CharConverter
{
	public static function main()
	{
		trace("Put Characters Folder Path!");
		var charFolder = Sys.stdin().readLine().trim();

		if (!FileSystem.isDirectory(charFolder))
		{
			trace('No Characters Folder Exists in ($charFolder) !!');
			return;
		}

		FileSystem.createDirectory(charFolder + "/converted/");
		for (file in FileSystem.readDirectory(charFolder))
		{
			if (!file.endsWith(".json"))
				continue;
			trace("converting " + file);
			var base:Dynamic = haxe.Json.parse(File.getContent(charFolder + "/" + file));
			
			var newJson:PsychCharacter = {
				animations: [],
				image: base.assetPath,
				scale: base.scale,
				sing_duration: base.singTime,
				healthicon: base.healthIcon.id,
				position: base.offsets,
				camera_position: base.cameraOffsets,
				flip_x: base.flipX,
				no_antialiasing: base.isPixel,
				vocals_file: base.healthIcon.id // lmao fuck that
			};

			for (i in 0...base.animations.length)
			{
				var baseAnim = base.animations[i];
				newJson.animations.push({
					anim: baseAnim.name,
					name: baseAnim.prefix,
					fps: baseAnim.frameRate,
					loop: baseAnim.looped,
					indices: baseAnim.frameIndices,
					offsets: baseAnim.offsets
				});
			}

			// fix shits
			if (newJson.vocals_file.startsWith("bf"))
				newJson.position[1] += 350;
			
			if (newJson.vocals_file.contains("pico") && newJson.vocals_file != "pico")
			{
				newJson.vocals_file = "pico-playable";
				newJson.position[1] += 300;
			}

			for (anim in newJson.animations)
			{
				if (anim.anim.contains("-hold"))
					anim.anim = anim.anim.replace("-hold", "-loop");
			}

			File.saveContent(charFolder + "/converted/" + file, haxe.Json.stringify(newJson, "\t"));
		}
	}
}

@:structInit class PsychCharacter
{
	public var animations:Array<PsychAnim> = [];
	public var image:String = "";
	public var scale:Float = 1;
	public var sing_duration:Float = 4;
	public var healthicon:String = "bf";

	public var position:Array<Float> = [0, 0];
	public var camera_position:Array<Float> = [0, 0];

	public var flip_x:Bool = false;
	public var no_antialiasing:Bool = false;
	public var healthbar_colors:Array<Int> = [255, 0, 0];
	public var vocals_file:String = "";
}

@:structInit class PsychAnim
{
	public var anim:String = "";
	public var name:String = "";
	public var fps:Int = 24;
	public var loop:Bool = false;
	public var indices:Array<Int> = [];
	public var offsets:Array<Int> = [0, 0];
}