package net.onthewings.bruceleemotion;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.hardware.Camera;
import android.hardware.Camera.Size;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.ImageView;

public class BruceLeeMotionActivity extends Activity implements Callback {
	private String testFrame = "http://192.168.1.101/~andy/2012-06-06%2002.55.40.png";
	private float picRatio = 16.0f / 9.0f;
	private Camera camera;
	private SurfaceView cameraSurfaceView;
	private SurfaceHolder cameraSurfaceHolder;
	private ImageView overlayView;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	setContentView(R.layout.main);
    	
    	cameraSurfaceView = (SurfaceView) findViewById(R.id.cameraSurfaceView);
    	cameraSurfaceHolder = cameraSurfaceView.getHolder();
    	cameraSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
	    cameraSurfaceHolder.setFormat(PixelFormat.TRANSLUCENT);
    	cameraSurfaceHolder.addCallback(this);
    	
    	overlayView = (ImageView) findViewById(R.id.overlayView);
    	try {
    		URL url = new URL(testFrame);
    		Bitmap bmp = BitmapFactory.decodeStream(url.openStream());
        	overlayView.setImageBitmap(bmp);
    	} catch (Exception e) {
			e.printStackTrace();
		}
    }
    
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		
		View decorView = getWindow().getDecorView();
        int viewWidth = (int) (decorView.getWidth() * 0.8);
        int viewHeight = (int) (decorView.getHeight() * 0.8);

        float surfaceRatio = (float)viewWidth/(float)viewHeight;
        if (surfaceRatio > picRatio) {
        	viewWidth = (int) (picRatio * viewHeight);
        } else if (surfaceRatio < picRatio) {
        	viewHeight = (int) (viewWidth / picRatio);
        }
        Log.d("view size", viewWidth + " " + viewHeight);

    	LayoutParams lparam;
    	lparam = cameraSurfaceView.getLayoutParams();
    	lparam.width = viewWidth;
    	lparam.height = viewHeight;
    	cameraSurfaceView.setLayoutParams(lparam);
    	
    	lparam = overlayView.getLayoutParams();
    	lparam.width = viewWidth;
    	lparam.height = viewHeight;
    	overlayView.setLayoutParams(lparam);
        
    }
    
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Rect surfaceFrame = holder.getSurfaceFrame();
        int thumbWidth = surfaceFrame.width();
        int thumbHeight = surfaceFrame.height();
        
        //in case the surface is not layouted yet
        if (thumbWidth < 10) return;
        
        Log.d("thumb size", thumbWidth + " " + thumbHeight);
        

        Camera.Parameters p = camera.getParameters();
        Size picSize = p.getPictureSize();
        
        /*
         * Find a largest picRatio(16:9) picture size.
         */
        Camera.Size pictureSize = null;
        for (Camera.Size s : p.getSupportedPictureSizes()) {
        	float ratio = (float) s.width / (float) s.height;
        	if (ratio == picRatio) {
        		if (pictureSize == null || s.width > pictureSize.width) {
        			pictureSize = s;
        		}
        	}
        }
        p.setPictureSize(pictureSize.width, pictureSize.height);
        Log.d("pictureSize", pictureSize.width + " " + pictureSize.height);
        
        /*
         * Find a picRatio(16:9) preview size
         */
        Camera.Size previewSize = null;
        for (Camera.Size s : p.getSupportedPreviewSizes()) {
        	float ratio = (float) s.width / (float) s.height;
        	if (ratio == picRatio) {
        		if (previewSize == null || Math.abs(s.width - thumbWidth) < Math.abs(previewSize.width - thumbWidth)) {
        			previewSize = s;
        		}
        	}
        }
        p.setPreviewSize(previewSize.width, previewSize.height);
        Log.d("previewSize", previewSize.width + " " + previewSize.height);
        
        try {
        	camera.setParameters(p);
        	camera.setPreviewDisplay(holder);
        } catch (IOException e) {
        	e.printStackTrace();
        }
        camera.startPreview();
        
        overlayView.bringToFront();
    }

    public void surfaceCreated(SurfaceHolder holder) {
    	camera = Camera.open();
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
        camera.stopPreview();
        camera.release();
    }
}