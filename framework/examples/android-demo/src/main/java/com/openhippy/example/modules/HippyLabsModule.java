package com.openhippy.example.modules;


import com.tencent.mtt.hippy.HippyEngineContext;
import com.tencent.mtt.hippy.annotation.HippyMethod;
import com.tencent.mtt.hippy.annotation.HippyNativeModule;
import com.tencent.mtt.hippy.modules.Promise;
import com.tencent.mtt.hippy.modules.javascriptmodules.EventDispatcher;
import com.tencent.mtt.hippy.modules.nativemodules.HippyNativeModuleBase;

import java.util.HashMap;
import java.util.Map;


/**
 *
 */
@HippyNativeModule(name = "HippyLabsModule")
public class HippyLabsModule extends HippyNativeModuleBase {

    public HippyLabsModule(HippyEngineContext context) {
        super(context);
    }

    //👉
    @HippyMethod(name = "sendMessage")
    public void sendMessage(final String message, final Promise promise) {
        //👉
        Map<String, String> retParams = new HashMap<>();
        retParams.put("message", "ModuleMsg：我是来自 Module(Java) 的消息\nVueMsg：" + message);
        dispatchEvent("onHippyLabsModuleEvent", retParams);

        //👉
        if (promise != null) {
            promise.resolve("return message from sendMessage method call");
        }
    }

    private void dispatchEvent(String eventName, Object eventParams) {
        if (mContext != null && mContext.getModuleManager().getJavaScriptModule(EventDispatcher.class) != null) {
            mContext.getModuleManager().getJavaScriptModule(EventDispatcher.class)//
                .receiveNativeEvent(eventName, eventParams);
        }
    }
}
