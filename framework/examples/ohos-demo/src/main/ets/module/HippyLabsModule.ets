import {
  HippyEngineContext,
  HippyAny,
  HippyNativeModule,
  HippyNativeModuleBase,
  HippyModulePromise,
  EventDispatcher,
  LogUtils
} from 'hippy';

@HippyNativeModule({ name: "HippyLabsModule" })
export class HippyLabsModule extends HippyNativeModuleBase {
  public static readonly NAME: string = 'HippyLabsModule'
  public readonly TAG: string = 'HippyLabsModule'

  constructor(ctx: HippyEngineContext) {
    super(ctx)
  }

  initialize(): void {
  }

  public call(method: string, params: Array<HippyAny>, promise: HippyModulePromise): HippyAny {
    switch (method) {
      case 'sendMessage': {
        const vueMessage = params[0] as string
        const event = new Map<string, HippyAny>()
        event.set("message", `ModuleMsg：我是来自 Module(ArkTS) 的消息\nVueMsg：${vueMessage}`)
        this.dispatchEvent("onHippyLabsModuleEvent", event)
        promise.resolve("return message from sendMessage method call")
        break;
      }
      default:
        super.call(method, params, promise);
    }
    return null;
  }

  dispatchEvent(eventName: string, eventParams: HippyAny) {
    try {
      if (this.ctx != null && this.ctx.getModuleManager() != null) {
        const eventModule =
          this.ctx.getModuleManager().getJavaScriptModule(EventDispatcher.MODULE_NAME);
        if (eventModule != null) {
          (eventModule as EventDispatcher).receiveNativeEvent(eventName, eventParams);
        }
      }
    } catch (e) {
      LogUtils.e('HippyLabsModule',
        'dispatchEvent: ' + eventName + ' eventParam:' + eventParams + " error!");
    }
  }
}
