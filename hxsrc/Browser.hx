package;

import haxe.Timer;
import js.Lib;
import jQuery.JQuery;

using StringTools;
using org.casalib.util.NumberUtil;

class Browser {
	static var images:Array<String> = [];
	static var currentIndex = -1;
	static var numOfFrames = 0;
	static var timer:Timer;
	static var fps:Float;
	
	static function imageLoop(fps:Float):Void {
		if (timer != null) timer.stop();
		if (fps == 0) {
			timer = null;
			return;
		}
		
		timer = new Timer(Std.int(1/fps * 1000));
    	timer.run = function(){
    		new JQuery("#bruce-" + currentIndex).hide();
    		currentIndex = (++currentIndex).loopIndex(numOfFrames);
    		new JQuery("#bruce-" + currentIndex).show();
    	}
    	
    	Browser.fps = fps;
	}
	
	static function getSuitableImageWidth():Int {
		var w = new JQuery(Lib.document).width();
		return if (w >= 800)
			800;
		else
			320;
	}
	
	static public function main():Void {
		
		/*
		 * preload images
		 */
		var progressbar = new JQuery("<div></div>").appendTo(new JQuery("#bruce"));
		untyped progressbar.progressbar();
		
		JQueryStatic.getJSON("motions/brucelee/comp_"+getSuitableImageWidth()+"/", {r:Math.random()}, function(json:Array<{comp:String}>){
			numOfFrames = json.length;
			for (item in json) {
				images.push(item.comp);
			}
			
			untyped new JQuery({}).imageLoader({
			    images: images,
			    async: 5,
			    complete: function(e, ui) {
			    	var i:Int = ui.i;
			    	progressbar.progressbar("value" , i.map(0, numOfFrames, 0, 100));
			    },
			    allcomplete: function(e, ui:Array<Dynamic>) {
			    	new JQuery(function(){
				    	var bruce = new JQuery("#bruce").html("");
				    	for (item in ui) {
				    		new JQuery(item.img).attr("id", "bruce-" + Std.string(item.i)).appendTo(bruce).hide();
				    	}
				    	
				    	imageLoop(12);
				    	
				    	new JQuery("#toggle-play-btn").click(function(evt:jQuery.Event){
				    		var btn = new JQuery("#toggle-play-btn");
				    		if (btn.html() == "pause") {
				    			imageLoop(0);
				    			btn.html("play");
				    		} else {
				    			imageLoop(fps);
				    			btn.html("pause");
				    		}
				    	});
				    	
				    	new JQuery("#toggle-slow-btn").click(function(evt:jQuery.Event){
				    		var btn = new JQuery("#toggle-slow-btn");
				    		if (btn.html() == "slow-mo") {
				    			if (timer != null)
				    				imageLoop(2);
				    			else
				    				fps = 2;
				    			btn.html("normal");
				    		} else {
				    			if (timer != null)
				    				imageLoop(12);
				    			else
				    				fps = 12;
				    			btn.html("slow-mo");
				    		}
				    	});
				    	
				    	new JQuery("#bruce-control").show("slow");
			    	});
			    }
			});
		});
		
		
		
		/*
		JQueryStatic.get("motions/brucelee/comp/thumb/" + index + "_" + thumb + ".png")
		
		new JQuery(
			function():Void {
				
			}
		);
		*/
	}
}