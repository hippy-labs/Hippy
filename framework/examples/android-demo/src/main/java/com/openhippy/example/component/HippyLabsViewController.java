package com.openhippy.example.component;

import static com.tencent.renderer.utils.EventUtils.EVENT_NATIVE_EVENT;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.tencent.mtt.hippy.annotation.HippyController;
import com.tencent.mtt.hippy.annotation.HippyControllerProps;
import com.tencent.mtt.hippy.dom.node.NodeProps;
import com.tencent.mtt.hippy.modules.Promise;
import com.tencent.mtt.hippy.uimanager.HippyGroupController;
import com.tencent.renderer.utils.EventUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 👉
 */
@HippyController(name = HippyLabsViewController.CLASS_NAME)
public class HippyLabsViewController extends HippyGroupController<HippyLabsView> {

    public static final String CLASS_NAME = "HippyLabsNativeElement";

    //
    private static final String OP_SEND_MESSAGE = "sendMessage";

    @Override
    protected View createViewImpl(Context context) {
        return new HippyLabsView(context);
    }

    @HippyControllerProps(name = NodeProps.MESSAGE, defaultType = HippyControllerProps.STRING)
    public void message(HippyLabsView labsView, String message) {
        labsView.setPropMessage(message);
    }

    @Override
    public void dispatchFunction(@NonNull HippyLabsView view, @NonNull String functionName, @NonNull List params, @NonNull Promise promise) {
        if (OP_SEND_MESSAGE.equals(functionName)) {
            if (params.size() > 0 && params.get(0) instanceof String) {
                String vueMessage = (String) params.get(0);

                Map<String, Object> eventParams = new HashMap<>();
                eventParams.put("code", 100);
                eventParams.put("message", "NativeMsg：我是来自 Native Android 的消息\nPropMsg：" + view.getPropMessage() + "\nVueMsg：" + vueMessage);
                //👉
                EventUtils.sendComponentEvent(view, EVENT_NATIVE_EVENT, eventParams);
                //👉
                promise.resolve("return message from method call");
            } else {
                promise.reject("INVALID_PARAM：Expected a string as the first parameter");
            }
            return;
        }

        super.dispatchFunction(view, functionName, params, promise);
    }
}
