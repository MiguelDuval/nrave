package org.mixxx;

import android.os.Build;
import android.os.Bundle;
import android.os.Process;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import org.qtproject.qt.android.QtActivityBase;

public class MainActivity extends QtActivityBase {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        fixNativeSplashAspectRatio(getWindow().getDecorView());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            getWindow().setPreferMinimalPostProcessing(true);
        }

        WindowManager.LayoutParams lp = this.getWindow().getAttributes();
        lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER;
        this.getWindow().setAttributes(lp);

        // Keep the DJ UI fullscreen and hide the navigation bar to avoid accidental exits.
        WindowInsetsControllerCompat windowInsetsController =
                WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.setSystemBarsBehavior(
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        windowInsetsController.hide(WindowInsetsCompat.Type.navigationBars());

        // Give the UI thread high display priority so Android does not starve the DJ surface.
        Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_DISPLAY);
    }

    private static boolean fixNativeSplashAspectRatio(View view) {
        if (view instanceof ImageView) {
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            if (layoutParams != null
                    && layoutParams.width == ViewGroup.LayoutParams.MATCH_PARENT
                    && layoutParams.height == ViewGroup.LayoutParams.MATCH_PARENT) {
                ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);
                return true;
            }
        }

        if (view instanceof ViewGroup) {
            ViewGroup group = (ViewGroup) view;
            for (int i = 0; i < group.getChildCount(); ++i) {
                if (fixNativeSplashAspectRatio(group.getChildAt(i))) {
                    return true;
                }
            }
        }
        return false;
    }
}
