import {
  HippyEngine,
  HippyException,
  HippyRoot,
  HippyRootViewWrapper,
  HippyLibrary,
  EngineInitParams,
  createHippyEngine,
  ModuleListener,
  EngineListener,
  EngineInitStatus,
  ModuleLoadParams,
  ModuleLoadStatus,
  HippyJsException,
  HippyValue,
} from 'hippy'
import HippyRenderBaseView
  from 'hippy/src/main/ets/renderer_native/components/base/HippyRenderBaseView'
import { LogUtils } from 'hippy/src/main/ets/support/utils/LogUtils'
import { BackPressHandler } from 'hippy/src/main/ets/hippy_framework/HippyEngine'
import { TestAPIProvider } from '../TestAPIProvider'

const TAG: string = 'IndexPage'

@Entry
@Component
struct Index {
  //TODO 调试地址
  private readonly DEBUG_SERVER_HOST = "192.168.40.77:38989"
  @StorageLink('libHippy') private libHippy: HippyLibrary | null = null
  @StorageLink('abilityContext') private abilityContext: Context | null = null
  //
  @State exception: string = ""
  private hippyEngine: HippyEngine | null = null
  private rootViewWrapper: HippyRootViewWrapper = new HippyRootViewWrapper()
  @State isEngineInitialized: boolean = false

  async aboutToAppear() {
    LogUtils.e(TAG, 'Lifecycle: aboutToAppear');
  }

  onPageShow(): void {
    LogUtils.e(TAG, 'Lifecycle: onPageShow');
    this.hippyEngine?.onEngineResume()
  }

  onPageHide(): void {
    LogUtils.e(TAG, 'Lifecycle: onPageHide');
    this.hippyEngine?.onEnginePause()
  }

  aboutToDisappear(): void {
    LogUtils.e(TAG, 'Lifecycle: aboutToDisappear');
  }

  onBackPress(): boolean | void {
    LogUtils.e(TAG, 'Lifecycle: onBackPress');
    this.hippyEngine?.onBackPressed(new RuntimeDefaultBackHandler())
    return false
  }

  initEngine() {
    LogUtils.e(TAG, 'initEngine start');
    //
    this.destroyEngine()
    //
    let params = new EngineInitParams(this.libHippy!, this.abilityContext!, this.getUIContext())
    params.enableArkCApi = true
    //TODO
    params.debugMode = true
    params.debugServerHost = this.DEBUG_SERVER_HOST

    params.enableLog = true
    //TODO 自定义 module 和 component 入口
    params.providers = [new TestAPIProvider()]
    //
    this.hippyEngine = createHippyEngine(params)
    let engineListener = new DefaultEngineListener(this.hippyEngine, this.rootViewWrapper)
    this.hippyEngine.initEngine(engineListener)
    this.isEngineInitialized = true
    LogUtils.e(TAG, 'initEngine end');
  }

  destroyEngine() {
    LogUtils.e(TAG, 'destroyEngine start');
    let rootView = this.rootViewWrapper?.getRootView()
    if (rootView) {
      this.rootViewWrapper?.resetRootView()
      this.hippyEngine?.destroyModule(rootView.getRootId(), () => {
        this.hippyEngine?.destroyEngine()
      });
    }
    this.isEngineInitialized = false
    LogUtils.e(TAG, 'destroyEngine end');
  }

  build() {
    Stack() {
      Column() {
        Button("调试: " + this.DEBUG_SERVER_HOST)
          .fontColor(Color.White)
          .fontSize(35)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#40b883')
          .type(ButtonType.Capsule)
          .width(800)
          .height(100)
          .onClick(() => {
            this.initEngine()
          })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .expandSafeArea()

      if (this.isEngineInitialized) {
        HippyRoot({
          hippyEngine: this.hippyEngine,
          rootViewWrapper: this.rootViewWrapper,
          onRenderException: (exception: HippyException) => {
            this.exception = `${exception.message}\n${exception.stack}`
            LogUtils.e(TAG, 'onRenderException: ' + this.exception);
          },
        }).layoutWeight(1)
      }
      if (this.exception) {
        Text(this.exception)
      }
    }
    .alignContent(Alignment.TopStart)
    .width('100%')
    .height('100%')
    .backgroundColor('#3394D0')
    .expandSafeArea()
  }
}


class DefaultEngineListener implements EngineListener {
  private hippyEngine: HippyEngine
  private rootViewWrapper: HippyRootViewWrapper

  constructor(hippyEngine: HippyEngine, rootViewWrapper: HippyRootViewWrapper) {
    this.hippyEngine = hippyEngine
    this.rootViewWrapper = rootViewWrapper
  }

  onInitialized(statusCode: EngineInitStatus, msg: string): void {
    LogUtils.e(TAG, 'initEngine status: ' + statusCode + ' msg:' + msg);
    if (statusCode == EngineInitStatus.STATUS_OK) {
      let loadParams = new ModuleLoadParams(
        'vue2/index.ohos.js',
        '',
        '',
        '',
        null,
        null,
        null,
      )
      //TODO
      loadParams.componentName = "Demo"
      loadParams.codeCacheTag = "Demo"
      loadParams.jsParams = new Map<string, HippyValue>()
      loadParams.jsParams.set(
        "msgFromNative",
        "Hi js developer, I come from ohos native code!"
      )
      loadParams.wrappedCustomRenderViewBuilder = wrapBuilder(buildCustomRenderView)
      let moduleListener = new DefaultModuleListener()
      let rootView = this.hippyEngine.loadModuleWithListener(loadParams, moduleListener)
      if (rootView) {
        this.rootViewWrapper.setRootView(rootView)
      }
    }
  }
}

class DefaultModuleListener implements ModuleListener {
  onLoadCompleted(statusCode: ModuleLoadStatus, msg: string): void {
    LogUtils.i(TAG, 'loadModule status: ' + statusCode + ' msg:' + msg);
  }

  onJsException(exception: HippyJsException): boolean {
    LogUtils.e(TAG, 'loadModule onJsException: ' + exception);
    return true;
  }

  onFirstViewAdded(): void {

  }

  onFirstContentfulPaint(): void {

  }
}


class RuntimeDefaultBackHandler implements BackPressHandler {
  handleBackPress(): void {
    console.log('Back button pressed');
  }
}

@Builder
function buildCustomRenderView($$: HippyRenderBaseView) {
}

