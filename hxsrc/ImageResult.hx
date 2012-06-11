package;

import haxe.io.Bytes;
import thx.error.NullArgument;
import ufront.web.mvc.ActionResult;
import ufront.web.mvc.ControllerContext;

class ImageResult extends ActionResult
{
	public var format:String;
	public var image:Bytes;

	public function new(image:Bytes, format:String)
	{
		NullArgument.throwIfNull(format);
		this.format = format;
		NullArgument.throwIfNull(image);
		this.image = image;
	}

	override function executeResult(controllerContext : ControllerContext)
	{
		NullArgument.throwIfNull(controllerContext);
		var response = controllerContext.response;
		response.contentType = switch(format.toLowerCase()) {
			case "jpeg", "jpg": "image/jpeg";
			case "png": "image/png";
			case "gif": "image/gif";
			default: throw "unknow image format: " + format;
		}
		
		response.setHeader("Content-Length", "" + image.length);
//		response.setHeader("Last-Modified", DateTools.format(Date.now(), '%a, %d %b %Y %H:%M:%S') + ' GMT');
		response.writeBytes(image, 0, image.length);
	}
}