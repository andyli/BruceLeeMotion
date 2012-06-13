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
	static public var ABSOLUT_PATH(default, never):String = Web.getHostName() == "localhost" ? "http://localhost/bruceleemotion.onthewings.net/" : "http://bruceleemotion.onthewings.net/";
	
	static function main():Void {
		Imports.pack("controller", true);
		var config = new AppConfiguration("controller", false);
		
		
		var routes = new RouteCollection();
        routes.addRoute("/", { controller : "home", action : "index" } );
        
        routes.addRoute("/motions/{id}/frame/{index}.png", { controller : "motions", action : "frame" } );
        routes.addRoute("/motions/{id}/frame/thumb/{index}_{thumb}.png", { controller : "motions", action : "frame" } );
        
        routes.addRoute("/motions/{id}/frame/random", { controller : "motions", action : "frame_random" } );
        routes.addRoute("/motions/{id}/frame/thumb/random_{thumb}", { controller : "motions", action : "frame_random" } );
        
        routes.addRoute("/motions/{id}/upload/{index}", { controller : "motions", action : "upload" } );
        
        routes.addRoute("/motions/{id}/photo/{index}/random", { controller : "motions", action : "photo" } );
        routes.addRoute("/motions/{id}/photo/thumb/{index}/random_{thumb}", { controller : "motions", action : "photo" } );
        
        routes.addRoute("/motions/{id}/comp/{index}.png", { controller : "motions", action : "comp" } );
        routes.addRoute("/motions/{id}/comp/thumb/{index}_{thumb}.png", { controller : "motions", action : "comp" } );
        
        
		var application = new MvcApplication(config, routes);
		
		if (Web.getHostName() == "localhost")
			application.httpContext.addUrlFilter(new DirectoryUrlFilter("bruceleemotion.onthewings.net"));		
		
		application.execute();
	}
}