/*
 * Tencent is pleased to support the open source community by making Hippy
 * available.
 * Copyright (C) 2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.openhippy.example

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowInsetsControllerCompat
import com.tencent.mtt.hippy.HippyAPIProvider
import com.tencent.mtt.hippy.HippyEngine
import com.tencent.mtt.hippy.HippyEngine.EngineInitParams
import com.tencent.mtt.hippy.HippyEngine.EngineInitStatus
import com.tencent.mtt.hippy.HippyEngine.EngineListener
import com.tencent.mtt.hippy.HippyEngine.ModuleListener
import com.tencent.mtt.hippy.HippyEngine.ModuleLoadParams
import com.tencent.mtt.hippy.HippyEngine.ModuleLoadStatus
import com.tencent.mtt.hippy.HippyEngine.create
import com.tencent.mtt.hippy.adapter.DefaultLogAdapter
import com.tencent.mtt.hippy.adapter.exception.HippyExceptionHandlerAdapter
import com.tencent.mtt.hippy.common.HippyJsException
import com.tencent.mtt.hippy.common.HippyMap
import com.tencent.mtt.hippy.utils.UIThreadUtils

class MainActivity : AppCompatActivity() {

  companion object {
    private const val TAG = "MainActivity"
    //👉
    private const val DEBUG_SERVER_HOST = "192.168.40.41:38989"
  }

  private lateinit var activityMainRoot: ViewGroup
  private var hippyEngine: HippyEngine? = null
  private lateinit var debugButton: Button
  private lateinit var hippyRootViewWrapper: ViewGroup

  var hippyRootView: ViewGroup? = null
  val driverMode: PageConfiguration.DriverMode = PageConfiguration.DriverMode.JS_VUE_3

  private var engineId: Int? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true
    activityMainRoot = layoutInflater.inflate(R.layout.activity_main, null) as ViewGroup
    setContentView(activityMainRoot)

    debugButton = activityMainRoot.findViewById<Button>(R.id.debug_button)
    hippyRootViewWrapper = activityMainRoot.findViewById<ViewGroup>(R.id.hippy_root_wrapper)
    debugButton.setText("调试：" + DEBUG_SERVER_HOST)
    debugButton.setOnClickListener { v ->
      initEngine()
    }
  }

  override fun onResume() {
    hippyEngine?.onEngineResume()
    super.onResume()
  }

  override fun onPause() {
    super.onPause()
    hippyEngine?.onEnginePause()
  }

  override fun onStop() {
    hippyEngine?.destroyModule(hippyRootView) { result, e ->
      hippyEngine?.destroyEngine()
    }
    hippyRootView = null
    super.onStop()
  }

  override fun onBackPressed() {
    super.onBackPressed()
    hippyEngine?.onBackPressed {}
  }

  private fun initEngine() {
    Log.d(TAG, "initEngine started")
    val initParams = EngineInitParams()
    initParams.context = this@MainActivity
    initParams.debugServerHost = DEBUG_SERVER_HOST
    //👉
    initParams.debugMode = true
    initParams.enableLog = true
    initParams.logAdapter = DefaultLogAdapter()
    initParams.groupId = 1
    when (driverMode) {
      PageConfiguration.DriverMode.JS_REACT -> {
        initParams.coreJSAssetsPath = "react/vendor.android.js"
      }

      PageConfiguration.DriverMode.JS_VUE_2 -> {
        initParams.coreJSAssetsPath = "vue2/vendor.android.js"
      }

      PageConfiguration.DriverMode.JS_VUE_3 -> {
        initParams.coreJSAssetsPath = "vue3/vendor.android.js"
      }

      PageConfiguration.DriverMode.VL -> {
        //TODO: Coming soon
      }
    }
    initParams.codeCacheTag = "common"
    initParams.exceptionHandler = object : HippyExceptionHandlerAdapter {
      override fun handleJsException(e: HippyJsException) {
        Log.e(TAG, "handleJsException :" + e.message)
      }

      override fun handleNativeException(e: Exception, haveCaught: Boolean) {
        Log.e(TAG, "handleNativeException :" + e.message)
      }

      override fun handleBackgroundTracing(details: String) {
        Log.e(TAG, "handleBackgroundTracing :$details")
      }
    }
    //👉
    val providers: MutableList<HippyAPIProvider> = ArrayList()
    //👉
    providers.add(ExampleAPIProvider())

    initParams.providers = providers
    initParams.enableTurbo = true
    hippyEngine = create(initParams)

    engineId = hippyEngine?.engineId
    Log.d(TAG, "initEngine end hippyEngine: $hippyEngine engineId: $engineId")
    //
    hippyEngine?.initEngine(object : EngineListener {
      override fun onInitialized(statusCode: EngineInitStatus, msg: String?) {
        if (statusCode == EngineInitStatus.STATUS_OK) {
          val loadParams = ModuleLoadParams()
          loadParams.context = this@MainActivity
          loadParams.componentName = "Demo"
          loadParams.codeCacheTag = "Demo"
          when (driverMode) {
            PageConfiguration.DriverMode.JS_REACT -> {
              loadParams.jsAssetsPath = "react/index.android.js"
            }

            PageConfiguration.DriverMode.JS_VUE_2 -> {
              loadParams.jsAssetsPath = "vue2/index.android.js"
            }

            PageConfiguration.DriverMode.JS_VUE_3 -> {
              loadParams.jsAssetsPath = "vue3/index.android.js"
            }

            PageConfiguration.DriverMode.VL -> {
              //TODO: Coming soon
            }
          }
          loadParams.jsFilePath = null
          loadParams.jsParams = HippyMap()
          loadParams.jsParams.pushString(
            "msgFromNative", "Hi js developer, I come from native code!"
          )
          hippyRootView = hippyEngine?.loadModule(loadParams, object : ModuleListener {
            override fun onLoadCompleted(statusCode: ModuleLoadStatus, msg: String?) {
              Log.e(TAG, "onLoadCompleted: statusCode: $statusCode msg:$msg")
            }

            override fun onJsException(exception: HippyJsException): Boolean {
              Log.e(TAG, "onJsException:" + exception.message)
              return true
            }

            override fun onFirstViewAdded() {
              Log.e(TAG, "onFirstViewAdded")
            }

            override fun onFirstContentfulPaint() {
              Log.e(TAG, "onFirstContentfulPaint")
            }
          })

          val loadCallbackTask = Runnable {
            hippyRootViewWrapper.addView(
              hippyRootView,
              ViewGroup.LayoutParams.MATCH_PARENT,
              ViewGroup.LayoutParams.MATCH_PARENT
            )
          }
          if (UIThreadUtils.isOnUiThread()) {
            loadCallbackTask.run()
          } else {
            UIThreadUtils.runOnUiThread {
              loadCallbackTask.run()
            }
          }
        }
      }
    })
  }
}
