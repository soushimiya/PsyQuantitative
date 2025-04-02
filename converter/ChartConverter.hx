package converter;

import sys.FileSystem;
import sys.io.File;

using StringTools;

class ChartConverter
{
	public static function main()
	{
		trace("Put Charts Folder Path!");
		var chartBaseFolder = Sys.stdin().readLine().trim();
		trace("Input Mix ID!");
		var mixName = Sys.stdin().readLine().trim();

		if (!FileSystem.isDirectory(chartBaseFolder))
		{
			trace('No Charts Folder Exists in ($chartBaseFolder) !!');
			return;
		}

		FileSystem.createDirectory(chartBaseFolder + "/_converted");
		for (folder in FileSystem.readDirectory(chartBaseFolder))
		{
			if (!FileSystem.isDirectory(chartBaseFolder + "/" + folder) || folder.startsWith("_"))
				continue;
			// also yep. if mix doesn't exists, skip it lmao
			if(!FileSystem.exists(chartBaseFolder + "/" + folder + "/" + '$folder-metadata$mixName.json'))
				continue;

			var metadata = haxe.Json.parse(File.getContent(chartBaseFolder + "/" + folder + "/" + '$folder-metadata$mixName.json'));
			var chart = haxe.Json.parse(File.getContent(chartBaseFolder + "/" + folder + "/" + '$folder-chart$mixName.json'));

			trace("converting " + metadata.songName + " by " + metadata.artist);
			FileSystem.createDirectory(chartBaseFolder + "/_converted/" + folder);

			// actual converting moment
			var diffs:Array<String> = metadata.playData.difficulties;
			for (difficulty in diffs)
			{
				var newChart:PsychSong = {
					song: metadata.songName,
					instrumental: "Inst" + mixName,
					bpm: metadata.timeChanges[0].bpm,
					speed: Reflect.field(chart.scrollSpeed, difficulty),

					player1: metadata.playData.characters.player,
					player2: metadata.playData.characters.opponent,
					gfVersion: metadata.playData.characters.girlfriend,
				};


				var notes:Array<VSliceNote> = Reflect.field(chart.notes, difficulty);

				//HEAVY WIP!!! FUCK SECTIONS!!
				
				newChart.notes.push({
					sectionBeats: 0,
					mustHitSection: false, // just to make looks better lmaooo
				});
				for (note in notes)
				{
					var noteData = note.d;
					if (noteData > 3)//dad note
						noteData = (noteData % 4);
					else
						noteData += 4;

					var noteLength:Float = 0;
					if (note.l != null)
						noteLength = note.l;

					var noteType:String = "";
					switch(note.k)
					{
						case "mom":
							noteType = "Alt Animation";
					}

					newChart.notes[0].sectionNotes.push([
						note.t,
						noteData,
						noteLength,
						noteType
					]);

				}

				var disDiff = "-" + difficulty;
				if (difficulty == "normal")
					disDiff = "";

				File.saveContent(chartBaseFolder + "/_converted/" + folder + "/" + '$folder$disDiff.json', haxe.Json.stringify({song: newChart}, "\t"));
			}

			var events:Array<VSliceEvents> = chart.events;
			var newEvents:Array<Dynamic> = [];
			for (event in events)
			{
				var newEvent:Array<String> = [];
				switch(event.e)
				{
					case "FocusCamera":
						newEvent = [
							"Focus Camera",
							// "dad",
							// "quadInOut,2"
						]
						if (event.v.char is Int)
							newEvent.push(["bf", "dad", "gf"][event.v.char]);
						else
							newEvent.push(event.v.char);
				}

				newEvents.push([
					event.t, [newEvent]
				]);
			}
			File.saveContent(chartBaseFolder + "/_converted/" + folder + "/events.json", haxe.Json.stringify({song: {events: newEvents}}, "\t"));
		}
	}
}

@:structInit class PsychSong
{
	public var song:String = "";
	public var instrumental:String = "";
	public var notes:Array<PsychSection> = [];
	public var events:Array<Dynamic> = [];
	public var bpm:Float = 100;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = "bf";
	public var player2:String = "dad";
	public var gfVersion:String = "gf";
	public var stage:String = "stage";
}

@:structInit class PsychSection
{
	public var sectionNotes:Array<Dynamic> = [];
	public var sectionBeats:Float = 16;
	public var mustHitSection:Bool = false;
	public var gfSection:Bool = false;
	public var bpm:Float = 0;
	public var changeBPM:Bool = false;
	public var altAnim:Bool = false;
}

// ToDo: implement notekind
typedef VSliceNote =
{
	var t:Float; // time
	var d:Int; // data
	var ?l:Float; // length
	var ?k:String; // type
}

typedef VSliceEvent =
{
	var t:Float;
	var e:String;
	var v:Dynamic;
}