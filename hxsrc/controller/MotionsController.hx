package controller;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
import ufront.web.mvc.Controller;
import ufront.web.mvc.JsonResult;
import php.imagemagick.Imagick;
import php.Web;
import haxe.io.Bytes;
import haxe.xml.Fast;
using org.casalib.util.ArrayUtil;

using Lambda;
using StringTools;
using DateTools;

class MotionsController extends Controller {
    static public var BASE_PATH(default, never):String = "motions/";
	
	/**
	 * Returns the image file name based on the index of the motion sequence.
	 */
	static public function imageFileName(index:Int, ?thumb:Int = 0):String {
		return Std.string(index).lpad("0", 4) + (thumb == 0 ? "" : "_" + thumb) + ".png";
	}
	
	/**
	 * Get the uri of thumbnail of an image. Creates the thumbnail if not exist.
	 */
	static function getThumb(path:String, index:Int, thumb:Int):String {
		var thumbPath = path + (thumb == 0 ? "" : "thumb/");
		var uri = thumbPath + imageFileName(index, thumb);
		if (FileSystem.exists(uri)) return uri;
		
		if (!FileSystem.exists(thumbPath)) FileSystem.createDirectory(thumbPath);
		
		var image = new Imagick(path + imageFileName(index));
		image.resizeImage(thumb, 0, Imagick.FILTER_LANCZOS, 1);
		image.writeImage(uri);
		
		return uri;
	}
	
	/**
	 * Similar to getThumb, but locate file by fileName instead of index.
	 */
	static function getPhotoThumb(path:String, fileName:String, thumb:Int):String {
		var thumbPath = path + (thumb == 0 ? "" : "thumb/");
		var thumbName = fileName.substr(0, fileName.lastIndexOf(".")) + (thumb == 0 ? "" : "_" + thumb) + fileName.substr(fileName.lastIndexOf("."));
		
		var uri = thumbPath + thumbName;
		if (FileSystem.exists(uri)) return uri;
		
		if (!FileSystem.exists(thumbPath)) FileSystem.createDirectory(thumbPath);
		
		var image = new Imagick(path + fileName);
		image.resizeImage(thumb, 0, Imagick.FILTER_LANCZOS, 1);
		image.writeImage(uri);
		
		return uri;
	}
	
	/**
	 * Get the uri of mask of an image.
	 */
	static function getMask(id:String, index:Int, ?thumb:Int = 0):String {
		var path = BASE_PATH + id + "/mask/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		
		var uri = path + imageFileName(index);
		if (FileSystem.exists(uri)) return uri;
		
		var image = new Imagick(getOriginal(id, index));
		var mask = new Imagick(getOriginal("global_mask", 0));
		
		if (image.getImageWidth() != mask.getImageWidth()) 
			mask = new Imagick(getOriginal("global_mask", 0, image.getImageWidth()));
		
		mask.writeImage(uri);
		
		return getThumb(path, index, thumb);
	}
	
	/**
	 * Get the uri of the original image.
	 */
	static function getOriginal(id:String, index:Int, ?thumb:Int = 0):String {
		var path = BASE_PATH + id + "/original/";
		if (!FileSystem.exists(path)) throw id + " does not exist.";
		
		if (thumb > 0)
			return getThumb(path, index, thumb);
		else
			return path + imageFileName(index, thumb);
	}
	
	/**
	 * Get the uri of the image frame for overlay.
	 */
	static function getFrame(id:String, index:Int, ?thumb:Int = 0) {
		var path = BASE_PATH + id + "/frame/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		
		var uri = path + imageFileName(index);
		if (!FileSystem.exists(uri)) {
			var image = new Imagick(getOriginal(id, index));
			
			var r = image.clone();
			r.separateImageChannel(Imagick.CHANNEL_RED);
			var g = image.clone();
			g.separateImageChannel(Imagick.CHANNEL_GREEN);
			var b = image.clone();
			b.separateImageChannel(Imagick.CHANNEL_BLUE);
			var a = new Imagick(getMask(id, index));
			
			var comp = new Imagick();
			comp.addImage(r);
			comp.addImage(g);
			comp.addImage(b);
			comp.addImage(a);
			comp.flattenImages();
			comp = comp.combineImages(Imagick.CHANNEL_RED | Imagick.CHANNEL_GREEN | Imagick.CHANNEL_BLUE | Imagick.CHANNEL_ALPHA);
			comp.writeImage(uri);
		}
		
		return getThumb(path, index, thumb);
	}
	
	static function getPhotoPath(id:String, index:Int):String {
		var path = BASE_PATH + id + "/photo/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		path += Std.string(index).lpad("0", 4) + "/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		
		return path;
	}
	
	static function getComp(id:String, index:Int, ?thumb:Int = 0):String {
		var path = BASE_PATH + id + "/comp/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		path += Std.string(index).lpad("0", 4) + "/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		
		function isJpg(f:String) return f.endsWith(".jpg");
		var photoFileNames = FileSystem
			.readDirectory(getPhotoPath(id, index))
			.filter(isJpg);
			
		if (!photoFileNames.empty()){
			var photoFileName = photoFileNames.random();
			var compFileName = photoFileName;
			
			var uri = path + compFileName;
			if (!FileSystem.exists(uri)) {
				var frame = new haxe.imagemagick.Imagick(getFrame(id, index));
				
				var comp = new haxe.imagemagick.Imagick(getPhotoPath(id, index) + photoFileName);
				comp.resize(frame.width, frame.height);
				comp.composite(frame, ImagickCompositeOperator.SrcAtop, 0, 0);
				comp.save(uri);
			}
			
			return getPhotoThumb(path, compFileName, thumb);
		} else {
			return getOriginal(id, index, thumb);
		}
	}
	
	static function getPhoto(id:String, index:Int, ?thumb:Int = 0):String {
		var path = getPhotoPath(id, index);
		
		function isJpg(f:String) return f.endsWith(".jpg");
		var photoFileName = FileSystem
			.readDirectory(path)
			.filter(isJpg)
			.random();
		var compFileName = photoFileName.replace(".jpg", ".png");
		
		var uri = path + compFileName;
		if (!FileSystem.exists(uri)) {
			var frame = new haxe.imagemagick.Imagick(getFrame(id, index));
			
			var comp = new haxe.imagemagick.Imagick(path + photoFileName);
			comp.resize(frame.width, frame.height);
			//comp.composite(frame, ImagickCompositeOperator.SrcAtop, 0, 0);
			comp.save(uri);
		}
		
		return getPhotoThumb(path, compFileName, thumb);
	}
	
	
	/**
	 * Action for "/motions/{id}/frame/{index}.png", "/motions/{id}/frame/thumb/{index}_{thumb}.png".
	 */
	public function frame(id:String, index:Int, ?thumb:Int = 0) {
		return new ImageResult(File.getBytes(getFrame(id, index, thumb)), "png");
	}
	
	/**
	 * Action for "/motions/{id}/frame/random", "/motions/{id}/frame/thumb/random_{thumb}".
	 */
	public function frame_random(id:String, ?thumb:Int = 0) {
		var info = new Fast(Xml.parse(File.getContent(BASE_PATH + id + "/info.xml")));
		var numOfFrames = Std.parseInt(info.node.info.att.numOfFrames);
		var index = Std.int(Math.random() * numOfFrames);
		return new JsonResult({
			index: index,
			frame: Server.ABSOLUT_PATH + getFrame(id, index, thumb),
			original: Server.ABSOLUT_PATH + getOriginal(id, index, thumb)
		});
	}
	
	/**
	 * Action for "/motions/{id}/upload/{index}"
	 */
	public function upload(id:String, index:Int) {
		var date = Date.fromString(controllerContext.request.post.get("date"));
		var uploadHandler = new UploadHandler(
			id, 
			index, 
			date
		);
		
		controllerContext.request.setUploadHandler(uploadHandler);
		while (!uploadHandler.isEnded)
			Sys.sleep(0.01);
		
		return new JsonResult({
			id: id,
			index: index,
			photo: Server.ABSOLUT_PATH + uploadHandler.path + uploadHandler.fileName
		});
		
	}
	
	/**
	 * Action for 
	 */
	public function photo(id:String, index:Int, ?thumb:Int = 0) {
		return new ImageResult(File.getBytes(getPhoto(id, index, thumb)), "jpg");
	}
	
	/**
	 * Action for 
	 */
	public function comp(id:String, index:Int, ?thumb:Int = 0) {
		return new ImageResult(File.getBytes(getComp(id, index, thumb)), "png");
	}
}

class UploadHandler implements ufront.web.IHttpUploadHandler {
	public var path(default, null):String;
	public var fileName(default, null):String;
	public var isEnded(default, null):Bool;
	
	var id:String;
	var index:Int;
	var date:Date;
	var file:FileOutput;
	public var processed(default, null):Int;
	
	public function new(id:String, index:Int, date:Date):Void {
		this.id = id;
		this.index = index;
		this.date = date;
		isEnded = false;
		processed = 0;
		
		path = MotionsController.BASE_PATH + id + "/photo/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		path += Std.string(index).lpad("0", 4) + "/";
		if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
	}
	
	public function uploadStart(name:String, filename:String):Void {
		var dateStr = date.format("%Y%m%d-%H%M%S");
		fileName = dateStr + ".jpg";
		if (FileSystem.exists(path + fileName)) {
			var num = 0;
			do {
				fileName = dateStr + "_" + Std.string(num++).lpad("0", 3) + ".jpg";
			} while (FileSystem.exists(path + fileName));
		}
		file = File.write(path + fileName, true);
	}
	
	public function uploadProgress(bytes:Bytes, pos:Int, len:Int):Void {
		isEnded = true;
		file.writeBytes(bytes, pos, len);
		processed += len;
	}
	
	public function uploadEnd():Void {
		file.close();
		isEnded = true;
	}
}