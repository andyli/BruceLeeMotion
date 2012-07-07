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
	static var isGetUserMediaSupported(default, never):Bool = untyped !!(navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia);
	
	public var displayMode(default, setDisplayMode):DisplayMode;
	var images:Array<String>;
	var currentIndex = -1;
	var numOfFrames = 0;
	var timer:Timer;
	var fps:Float;
	var videoCapTimer:Timer;
	
	/*
	 * draw video stream onto canvas so that we will have complete control on the display
	 */
	function startVideo():Void {
		stopVideo(); //in case has already started
		
		var video = new JQuery("#capture video");
	 	var canvasj = new JQuery("#capture canvas");
		var canvas:Canvas = cast canvasj[0];
		var ctx = canvas.getContext("2d");
		var videoEle:HTMLVideoElement = cast video[0];
		var canvasRatio = canvas.width/canvas.height;
		var videoEleRatio = videoEle.videoWidth/videoEle.videoHeight;
		
		videoCapTimer = new Timer(Std.int(1/24 * 1000));
	
		if (canvasRatio == videoEleRatio) {
			var scaledWidth = canvas.width;
			var scaledHeight = canvas.height;
			
			videoCapTimer.run = function () {
				ctx.drawImage(videoEle, 0, 0, scaledWidth, scaledHeight);
			}
		} else if (canvasRatio > videoEleRatio) {
			var scaledWidth = canvas.width;
			var scaledHeight = scaledWidth/videoEleRatio;
			var y = (scaledHeight - canvas.height) * -0.5;
			
			videoCapTimer.run = function () {
				ctx.drawImage(videoEle, 0, y, scaledWidth, scaledHeight);
			}
		} else {
			var scaledHeight = canvas.height;
			var scaledWidth = videoEleRatio * scaledHeight;
			var x = (scaledWidth - canvas.width) * -0.5;
			
			videoCapTimer.run = function () {
				ctx.drawImage(videoEle, x, 0, scaledWidth, scaledHeight);
			}
		}
	}
	
	function stopVideo():Void {
		if (videoCapTimer != null) {
			videoCapTimer.stop();
			videoCapTimer = null;
		}
	}
	
	function setDisplayMode(v:DisplayMode) {
		var pDisplayMode = displayMode;
		displayMode = v;
		
		if (pDisplayMode == null || pDisplayMode.enumEq(displayMode)) return displayMode;
		
		switch (pDisplayMode) {
			case PlaybackMode:
				imageLoop(0);
			case CaptureMode:
				stopVideo();
				new JQuery("#capture video").removeAttr("src");
				new JQuery("#capture").removeClass("captured");
				new JQuery("#capture-take-btn").html("take picture");
		}
		
		switch (displayMode) {
			case PlaybackMode:
				imageLoop(fps);
			case CaptureMode:
				if (!isGetUserMediaSupported) {
					Lib.alert("getUserMedia() is not supported or not enabled in your browser.");
				} else {
					var video = new JQuery("#capture video");
					var display = new JQuery("#display");
					
					new JQuery("#capture canvas")
						.attr("width", display.width())
						.attr("height", display.height());
					
					(untyped navigator.getUserMedia)({video: true}, function(stream) {
						untyped video.attr("src", navigator.webkitGetUserMedia ? window.webkitURL.createObjectURL(stream) : stream);
						
						video.bind("playing", function(evt:jQuery.Event){ //when start playing
							new JQuery("#capture-take-btn").removeAttr("disabled");
						
							startVideo();
						});
					}, function(err) {
						Lib.alert("Error: " + err);
					});
				}
		}
		
		var mainDiv = new JQuery("#main");
		mainDiv.removeClass(pDisplayMode.enumConstructor());
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
		new JQuery("#toggle-play-btn").click(function(evt:jQuery.Event){
    		if (new JQuery("#toggle-play-btn").html() == "pause") {
    			imageLoop(0);
    		} else {
    			imageLoop(fps);
    		}
    	}).attr("disabled", true);
    	
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
    	}).attr("disabled", true);
		
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
			    async: 10,
			    complete: function(e, ui) {
			    	progressbar.progressbar("value" , (++loaded).map(0, numOfFrames, 0, 100));
			    },
			    allcomplete: function(e, ui:Array<Dynamic>) {
			    	new JQuery(function(){
				    	var playback = new JQuery("#playback").html("");
				    	for (item in ui) {
				    		new JQuery(item.img).attr("id", "playback-" + Std.string(item.i)).appendTo(playback).hide();
				    	}
				    	
				    	if (displayMode.enumEq(PlaybackMode))
				    		imageLoop(12);
				    	
				    	new JQuery("#toggle-play-btn").removeAttr("disabled");
				    	new JQuery("#toggle-slow-btn").removeAttr("disabled");
				    	
				    	new JQuery("#main").removeClass("loading");
			    	});
			    }
			});
		});
		
		/*
		 * CaptureMode
		 */
		new JQuery("#toggle-capture-btn").click(function(evt:jQuery.Event){			
			switch (displayMode) {
				case PlaybackMode:
					displayMode = CaptureMode;
					new JQuery("#toggle-capture-btn").html("cancel");
				case CaptureMode:
					displayMode = PlaybackMode;
					new JQuery("#toggle-capture-btn").html("Insert your own!");
			}
		});
		
		new JQuery("#capture-take-btn").click(function(evt:jQuery.Event){
			var capture = new JQuery("#capture");
			if (!capture.hasClass("captured")) {
				stopVideo();
				
				capture.addClass("captured");
				new JQuery("#capture-take-btn").html("retake");
			} else {
				startVideo();
				
				capture.removeClass("captured");
				new JQuery("#capture-take-btn").html("take picture");
			}
		}).attr("disabled", true);	
	}
	
	static function main():Void {
		instance = new Browser();
	}
}