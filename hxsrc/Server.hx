package;

import haxe.xml.Fast;
import sys.FileSystem;
import sys.io.File;
import php.Lib;
import php.Web;
import thx.util.Imports;
import ufront.web.AppConfiguration;
import ufront.web.DirectoryUrlFilter;
import ufront.web.mvc.MvcApplication;
import ufront.web.routing.RouteCollection;

class Server {
	static function main():Void {
		Imports.pack("controller");
		var config = new AppConfiguration("controller", false);
		
		var routes = new RouteCollection();
        routes.addRoute("/", { controller : "home", action : "index" } );
        routes.addRoute("/motions/{id}/frame/{index}.png", { controller : "motions", action : "frame" } );
        routes.addRoute("/motions/{id}/frame/thumb/{index}_{thumb}.png", { controller : "motions", action : "frame" } );
        
		var application = new MvcApplication(config, routes);
		
		if (Web.getHostName() == "localhost")
			application.httpContext.addUrlFilter(new DirectoryUrlFilter("bruceleemotion.onthewings.net"));		
		
		application.execute();
		
		//var info = new Fast(Xml.parse(File.getContent("motions/brucelee/info.xml")));
		//trace(info.node.info.att.name);
	}
}