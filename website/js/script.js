var $estr = function() { return js.Boot.__string_rec(this,''); };
var Browser = function() {
	this.numOfFrames = 0;
	this.currentIndex = -1;
	var _g = this;
	this.setDisplayMode(DisplayMode.PlaybackMode);
	var progressbar = new $("<div></div>").appendTo(new $("#playback"));
	progressbar.progressbar(null);
	progressbar.hide().fadeTo("slow",0.8);
	$.getJSON("motions/brucelee/comp_" + Browser.getSuitableImageWidth() + "/",{ r : Math.random()},function(json) {
		_g.numOfFrames = json.length;
		_g.images = [];
		var _g1 = 0;
		while(_g1 < json.length) {
			var item = json[_g1];
			++_g1;
			_g.images.push(item.comp);
		}
		var loaded = 0;
		new $({ }).imageLoader({ images : _g.images, async : 5, complete : function(e,ui) {
			var a1 = 100 * (++loaded / _g.numOfFrames);
			if(a1 != null) progressbar.progressbar("value",a1); else progressbar.progressbar("value");
		}, allcomplete : function(e,ui) {
			new $(function() {
				var playback = new $("#playback").html("");
				var _g1 = 0;
				while(_g1 < ui.length) {
					var item = ui[_g1];
					++_g1;
					new $(item.img).attr("id","playback-" + Std.string(item.i)).appendTo(playback).hide();
				}
				_g.imageLoop(12);
				new $("#toggle-play-btn").click(function(evt) {
					if(new $("#toggle-play-btn").html() == "pause") _g.imageLoop(0); else _g.imageLoop(_g.fps);
				});
				new $("#toggle-slow-btn").click(function(evt) {
					var btn = new $("#toggle-slow-btn");
					if(btn.html() == "slow-mo") {
						if(_g.timer != null) _g.imageLoop(2); else _g.fps = 2;
						btn.html("normal");
					} else {
						if(_g.timer != null) _g.imageLoop(12); else _g.fps = 12;
						btn.html("slow-mo");
					}
				});
				new $("#main").removeClass("loading");
			});
		}});
	});
	navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;
	new $("#toggle-capture-btn").click(function(evt) {
		_g.setDisplayMode(DisplayMode.CaptureMode);
	});
};
Browser.__name__ = true;
Browser.getSuitableImageWidth = function() {
	var w = new $(js.Lib.document).width();
	return w >= 800?800:320;
}
Browser.main = function() {
	Browser.instance = new Browser();
}
Browser.prototype = {
	imageLoop: function(fps) {
		var _g = this;
		if(this.timer != null) this.timer.stop();
		if(fps == 0) {
			this.timer = null;
			new $("#toggle-play-btn").html("play");
			return;
		}
		this.timer = new haxe.Timer(1 / fps * 1000 | 0);
		this.timer.run = function() {
			new $("#playback-" + _g.currentIndex).hide();
			_g.currentIndex = org.casalib.util.NumberUtil.loopIndex(++_g.currentIndex,_g.numOfFrames);
			new $("#playback-" + _g.currentIndex).show();
		};
		this.fps = fps;
		new $("#toggle-play-btn").html("pause");
	}
	,setDisplayMode: function(v) {
		if(Type.enumEq(this.displayMode,v)) return v;
		var pDisplayMode = this.displayMode;
		this.displayMode = v;
		if(pDisplayMode == null) return v;
		var mainDiv = new $("#main");
		mainDiv.removeClass(pDisplayMode[0]);
		switch( (pDisplayMode)[1] ) {
		case 0:
			this.imageLoop(0);
			break;
		case 1:
			break;
		}
		switch( (this.displayMode)[1] ) {
		case 0:
			this.imageLoop(this.fps);
			break;
		case 1:
			if(!navigator.getUserMedia) js.Lib.alert("getUserMedia() is not supported or not enabled in your browser."); else {
				var videoDiv = new $("#capture video");
				videoDiv.height(videoDiv.width() / (16 / 9)).fadeIn();
				navigator.getUserMedia({ video : true},function(stream) {
					videoDiv.attr("src",navigator.webkitGetUserMedia?window.webkitURL.createObjectURL(stream):stream);
				},function(err) {
					js.Lib.alert("Error: " + err);
				});
			}
			break;
		}
		mainDiv.addClass(this.displayMode[0]);
		return this.displayMode;
	}
}
var BrowserConfig = function() { }
BrowserConfig.__name__ = true;
var DisplayMode = { __ename__ : true, __constructs__ : ["PlaybackMode","CaptureMode"] }
DisplayMode.PlaybackMode = ["PlaybackMode",0];
DisplayMode.PlaybackMode.toString = $estr;
DisplayMode.PlaybackMode.__enum__ = DisplayMode;
DisplayMode.CaptureMode = ["CaptureMode",1];
DisplayMode.CaptureMode.toString = $estr;
DisplayMode.CaptureMode.__enum__ = DisplayMode;
var Std = function() { }
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
var Type = function() { }
Type.__name__ = true;
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
var haxe = haxe || {}
haxe.Timer = function(time_ms) {
	var me = this;
	this.id = window.setInterval(function() {
		me.run();
	},time_ms);
};
haxe.Timer.__name__ = true;
haxe.Timer.prototype = {
	run: function() {
	}
	,stop: function() {
		if(this.id == null) return;
		window.clearInterval(this.id);
		this.id = null;
	}
}
var js = js || {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Lib = function() { }
js.Lib.__name__ = true;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
var org = org || {}
if(!org.casalib) org.casalib = {}
if(!org.casalib.math) org.casalib.math = {}
org.casalib.math.Percent = function() { }
org.casalib.math.Percent.__name__ = true;
if(!org.casalib.util) org.casalib.util = {}
org.casalib.util.NumberUtil = function() { }
org.casalib.util.NumberUtil.__name__ = true;
org.casalib.util.NumberUtil.loopIndex = function(index,length) {
	if(index < 0) index = length + index % length;
	if(index >= length) index %= length;
	return index;
}
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.__name__ = true;
Array.__name__ = true;
js.XMLHttpRequest = window.XMLHttpRequest?XMLHttpRequest:window.ActiveXObject?function() {
	try {
		return new ActiveXObject("Msxml2.XMLHTTP");
	} catch( e ) {
		try {
			return new ActiveXObject("Microsoft.XMLHTTP");
		} catch( e1 ) {
			throw "Unable to create XMLHttpRequest object.";
		}
	}
}:(function($this) {
	var $r;
	throw "Unable to create XMLHttpRequest object.";
	return $r;
}(this));
if(typeof document != "undefined") js.Lib.document = document;
if(typeof window != "undefined") {
	js.Lib.window = window;
	js.Lib.window.onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if(f == null) return false;
		return f(msg,[url + ":" + line]);
	};
}
Browser.main();
