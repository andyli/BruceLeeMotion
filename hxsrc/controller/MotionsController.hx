package controller;

import sys.FileSystem;
import sys.io.File;
import ufront.web.mvc.Controller;
import php.imagemagick.Imagick;

using StringTools;

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
	static function getThumb(path:String, index:Int, thumb:Int) {
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
	 * Get the uri of mask of an image.
	 */
	static function getMask(id:String, index:Int, ?thumb:Int = 0) {
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
	static function getOriginal(id:String, index:Int, ?thumb:Int = 0) {
		var path = BASE_PATH + id + "/original/";
		if (!FileSystem.exists(path)) throw id + " does not exist.";
		
		if (thumb > 0)
			return getThumb(path, index, thumb);
		else
			return path + imageFileName(index, thumb);
	}
	
	
	/**
	 * Action for "/motions/{id}/frame/{index}.png", "/motions/{id}/frame/thumb/{index}_{thumb}.png".
	 */
	public function frame(id:String, index:Int, ?thumb:Int = 0) {
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
		
		return new ImageResult(File.getBytes(getThumb(path, index, thumb)), "png");
	}
}