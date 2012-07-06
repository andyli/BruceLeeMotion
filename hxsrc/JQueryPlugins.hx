import jQuery.JQuery;

extern class JQueryPlugins {
	inline static function imageLoader(j:JQuery, config:Dynamic):JQuery {
		return untyped j.imageLoader(config);
	}
	
	inline static function progressbar(j:JQuery, ?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic):JQuery {
		return if (a2 != null)
			untyped j.progressbar(a0, a1, a2);
		else if (a1 != null)
			untyped j.progressbar(a0, a1);
		else
			untyped j.progressbar(a0);
	}
}