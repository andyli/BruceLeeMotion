var Browser = function() { }
Browser.__name__ = true;
Browser.imageLoop = function(fps) {
	if(Browser.timer != null) Browser.timer.stop();
	if(fps == 0) return;
	Browser.timer = new haxe.Timer(1 / fps * 1000 | 0);
	Browser.timer.run = function() {
		new $("#bruce-" + Browser.currentIndex).hide();
		Browser.currentIndex = org.casalib.util.NumberUtil.loopIndex(++Browser.currentIndex,Browser.numOfFrames);
		new $("#bruce-" + Browser.currentIndex).show();
	};
	Browser.fps = fps;
}
Browser.getSuitableImageWidth = function() {
	var w = new $(js.Lib.document).width();
	return w >= 800?800:320;
}
Browser.main = function() {
	$.getJSON("motions/brucelee/comp_" + Browser.getSuitableImageWidth() + "/",{ r : Math.random()},function(json) {
		Browser.numOfFrames = json.length;
		var _g = 0;
		while(_g < json.length) {
			var item = json[_g];
			++_g;
			Browser.images.push(item.comp);
		}
		new $({ }).imageLoader({ images : Browser.images, async : 5, allcomplete : function(e,ui) {
			new $(function() {
				var bruce = new $("#bruce").html("");
				var _g = 0;
				while(_g < ui.length) {
					var item = ui[_g];
					++_g;
					new $(item.img).attr("id","bruce-" + Std.string(item.i)).appendTo(bruce).hide();
				}
				Browser.imageLoop(12);
				new $("#toggle-play-btn").click(function(evt) {
					var btn = new $("#toggle-play-btn");
					if(btn.html() == "pause") {
						Browser.imageLoop(0);
						btn.html("play");
					} else {
						Browser.imageLoop(Browser.fps);
						btn.html("pause");
					}
				});
				new $("#toggle-slow-btn").click(function(evt) {
					var btn = new $("#toggle-slow-btn");
					if(btn.html() == "slow-mo") {
						Browser.imageLoop(2);
						btn.html("normal");
					} else {
						Browser.imageLoop(12);
						btn.html("slow-mo");
					}
				});
			});
		}});
	});
}
var Std = function() { }
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
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
	stop: function() {
		if(this.id == null) return;
		window.clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
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
Browser.images = [];
Browser.currentIndex = -1;
Browser.numOfFrames = 0;
Browser.main();
