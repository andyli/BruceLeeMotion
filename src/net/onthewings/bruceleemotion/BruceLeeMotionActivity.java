package net.onthewings.bruceleemotion;

import java.io.IOException;
import java.util.List;

import android.app.Activity;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.Size;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;

public class BruceLeeMotionActivity extends Activity implements Callback {
	private float picRatio = 16.0f / 9.0f;
	private Camera camera;
	private SurfaceView surfaceView;
	private SurfaceHolder surfaceHolder;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	setContentView(R.layout.main);
    	surfaceView = (SurfaceView) findViewById(R.id.cameraView);
    	surfaceHolder = surfaceView.getHolder();
    	surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
	    surfaceHolder.setFormat(PixelFormat.TRANSLUCENT);
    	surfaceHolder.addCallback(this);
    }
    
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);

    	LayoutParams lparam = surfaceView.getLayoutParams();

        int viewWidth = (int) (getWindow().getDecorView().getWidth() * 0.8);
        int viewHeight = (int) (getWindow().getDecorView().getHeight() * 0.8);

        float surfaceRatio = (float)viewWidth/(float)viewHeight;
        if (surfaceRatio > picRatio) {
        	viewWidth = (int) (picRatio * viewHeight);
        } else if (surfaceRatio < picRatio) {
        	viewHeight = (int) (viewWidth / picRatio);
        }
        
    	lparam.width = viewWidth;
    	lparam.height = viewHeight;
    	surfaceView.setLayoutParams(lparam);
        Log.d("view size", viewWidth + " " + viewHeight);
    	
		/*
		Log.d("hasFocus", "" + hasFocus);
		if (hasFocus) {
			SurfaceView view1 = (SurfaceView) findViewById(R.id.view1);
			
			Camera.Parameters camParam = camera.getParameters();
	        camParam.setJpegQuality(100);
	        //camParam.setPreviewSize(view1.getWidth(), view1.getHeight());
	        camera.setParameters(camParam);
	        
	        SurfaceHolder holder = view1.getHolder();
	        try {
	        	camera.setPreviewDisplay(holder);
	        	camera.startPreview();
	        } catch (IOException e) {
	        	e.printStackTrace();
	        }
	        
		} else {
			camera.stopPreview();
			camera.release();
		}
		*/
    }
    
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        
        int thumbWidth = holder.getSurfaceFrame().width();
        int thumbHeight = holder.getSurfaceFrame().height();
        
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
    }

    public void surfaceCreated(SurfaceHolder holder) {
    	camera = Camera.open();
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
        camera.stopPreview();
        camera.release();
    }
}