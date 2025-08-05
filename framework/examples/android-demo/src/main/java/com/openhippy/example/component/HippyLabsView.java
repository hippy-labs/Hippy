package com.openhippy.example.component;

import android.content.Context;
import android.view.MotionEvent;

import com.tencent.mtt.hippy.uimanager.HippyViewBase;
import com.tencent.mtt.hippy.uimanager.NativeGestureDispatcher;
import com.tencent.renderer.component.FlatViewGroup;

/**
 *
 */
public class HippyLabsView extends FlatViewGroup implements HippyViewBase {

    protected NativeGestureDispatcher mGestureDispatcher;

    private String propMessage = "";

    public HippyLabsView(Context context) {
        super(context);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        boolean result = super.onTouchEvent(event);
        if (mGestureDispatcher != null) {
            result |= mGestureDispatcher.handleTouchEvent(event);
        }
        return result;
    }

    @Override
    public NativeGestureDispatcher getGestureDispatcher() {
        return mGestureDispatcher;
    }

    @Override
    public void setGestureDispatcher(NativeGestureDispatcher dispatcher) {
        mGestureDispatcher = dispatcher;
    }

    public String getPropMessage() {
        return propMessage;
    }

    public void setPropMessage(String propMessage) {
        this.propMessage = propMessage;
    }
}
