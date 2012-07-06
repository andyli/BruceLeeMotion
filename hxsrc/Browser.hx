package;

import haxe.Timer;
import js.Lib;
import jQuery.JQuery;
import DisplayMode;

using Reflect;
using Type;
using StringTools;
using org.casalib.util.NumberUtil;
using JQueryPlugins;

class Browser {
	
	static function getSuitableImageWidth():Int {
		var w = new JQuery(Lib.document).width();
		return if (w >= 800)
			800;
		else
			320;
	}
	
	static var instance:Browser;
	
	public var displayMode(default, setDisplayMode):DisplayMode;
	var images:Array<String>;
	var currentIndex = -1;
	var numOfFrames = 0;
	var timer:Timer;
	var fps:Float;
	
	function setDisplayMode(v:DisplayMode) {
		if (displayMode.enumEq(v)) return v;
		
		var pDisplayMode = displayMode;
		displayMode = v;
		
		if (pDisplayMode == null) return v;
		
		var mainDiv = new JQuery("#main");
		mainDiv.removeClass(pDisplayMode.enumConstructor());
		
		switch (pDisplayMode) {
			case PlaybackMode:
				imageLoop(0);
			case CaptureMode:
				
		}
		
		switch (displayMode) {
			case PlaybackMode:
				imageLoop(fps);
			case CaptureMode:
				if (untyped !navigator.getUserMedia) {
					Lib.alert("getUserMedia() is not supported or not enabled in your browser.");
				} else {
					var videoDiv = new JQuery("#capture video");
				
					videoDiv
						.height(videoDiv.width() / (16/9))
						.fadeIn();
					
					untyped navigator.getUserMedia({video: true}, function(stream) {
						videoDiv.attr("src", navigator.webkitGetUserMedia ? window.webkitURL.createObjectURL(stream) : stream);
					}, function(err) {
						Lib.alert("Error: " + err);
					});
				}
		}
		
		mainDiv.addClass(displayMode.enumConstructor());
		return displayMode;
	}
	
	function imageLoop(fps:Float):Void {
		if (timer != null) timer.stop();
		if (fps == 0) {
			timer = null;
			new JQuery("#toggle-play-btn").html("play");
			return;
		}
		
		timer = new Timer(Std.int(1/fps * 1000));
    	timer.run = function(){
    		new JQuery("#playback-" + currentIndex).hide();
    		currentIndex = (++currentIndex).loopIndex(numOfFrames);
    		new JQuery("#playback-" + currentIndex).show();
    	}
    	
    	this.fps = fps;
    	new JQuery("#toggle-play-btn").html("pause");
	}
	
	public function new():Void {
		displayMode = BrowserConfig.INIT_DISPLAY_MODE;
		
		/*
		 * PlaybackMode
		 */
		var progressbar = new JQuery("<div></div>").appendTo(new JQuery("#playback"));
		untyped progressbar.progressbar();
		progressbar.hide().fadeTo("slow", 0.8);
		
		JQueryStatic.getJSON("motions/brucelee/comp_"+getSuitableImageWidth()+"/", {r:Math.random()}, function(json:Array<{comp:String}>){
			numOfFrames = json.length;
			images = [];
			for (item in json) {
				images.push(item.comp);
			}
			
			var loaded = 0;
			new JQuery({}).imageLoader({
			    images: images,
			    async: 5,
			    complete: function(e, ui) {
			    	progressbar.progressbar("value" , (++loaded).map(0, numOfFrames, 0, 100));
			    },
			    allcomplete: function(e, ui:Array<Dynamic>) {
			    	new JQuery(function(){
				    	var playback = new JQuery("#playback").html("");
				    	for (item in ui) {
				    		new JQuery(item.img).attr("id", "playback-" + Std.string(item.i)).appendTo(playback).hide();
				    	}
				    	
				    	imageLoop(12);
				    	
				    	new JQuery("#toggle-play-btn").click(function(evt:jQuery.Event){
				    		if (new JQuery("#toggle-play-btn").html() == "pause") {
				    			imageLoop(0);
				    		} else {
				    			imageLoop(fps);
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
				    	
				    	new JQuery("#main").removeClass("loading");
			    	});
			    }
			});
		});
		
		/*
		 * CaptureMode
		 */
		untyped navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;
		
		new JQuery("#toggle-capture-btn").click(function(evt:jQuery.Event){			
			displayMode = CaptureMode;
		});
	}
	
	static function main():Void {
		instance = new Browser();
	}
}