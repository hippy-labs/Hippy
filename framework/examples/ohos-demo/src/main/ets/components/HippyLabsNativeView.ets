import {
  HippyObservedArray,
  NativeRenderContext,
  HippyAny,
  HippyRenderCallback,
  HIPPY_COMPONENT_KEY_PREFIX,
  HippyViewEvent,
  buildHippyRenderView,
  HippyCustomComponentView,
} from 'hippy'

import HippyRenderBaseView
  from 'hippy/src/main/ets/renderer_native/components/base/HippyRenderBaseView'

@Observed
export class HippyLabsNativeView extends HippyCustomComponentView {
  propValue: string = ""

  constructor(ctx: NativeRenderContext) {
    super(ctx)
  }

  setProp(propKey: string, propValue: HippyAny): boolean {
    if (propKey == "message") {
      this.propValue = String(propValue)
      return true
    }
    return super.setProp(propKey, propValue)
  }

  call(method: string, params: Array<HippyAny>, callback: HippyRenderCallback | null): void {
    switch (method) {
      case "sendMessage": {
        //
        if (!params || params.length === 0 || typeof params[0] !== 'string') {
          console.warn("Invalid params passed to sendMessage")
          return
        }
        const vueMessage = params[0] as string
        let event = new HippyViewEvent("onNativeEvent")
        let eventParams = new Map<string, HippyAny>()
        eventParams.set('code', 100)
        eventParams.set('message',
          `NativeMsg：我是来自 Native 的消息\nPropMsg：${this.propValue}\nVueMsg：${vueMessage}`)
        event.send(this.ctx, this.tag, eventParams)
        //
        callback?.("return message from method call")
        return
      }
      default:
        console.warn(`Unhandled method: ${method}`)
        break
    }
    super.call(method, params, callback)
  }
}

@Component
export struct HippyLabsNativeViewElement {
  @ObjectLink renderView: HippyLabsNativeView
  @ObjectLink children: HippyObservedArray<HippyRenderBaseView>

  aboutToAppear(): void {
  }

  aboutToDisappear() {
  }

  build(): void {
    Stack() {
      ForEach(this.children, (item: HippyRenderBaseView) => {
        buildHippyRenderView(item, null)
      }, (item: HippyRenderBaseView) => item.tag + '')
      ContentSlot(this.renderView.childSlot)
    }
    .applyRenderViewBaseAttr(this.renderView)
  }
}

@Extend(Stack)
function applyRenderViewBaseAttr($$: HippyRenderBaseView) {
  .key(HIPPY_COMPONENT_KEY_PREFIX + $$.tag)
  .backgroundColor($$.cssBackgroundColor)
  .position({ x: $$.cssPositionX, y: $$.cssPositionY })
  .size({ width: $$.cssWidth, height: $$.cssHeight })
  .opacity($$.cssOpacity)
  .clip($$.cssOverflow)
  .visibility(($$ as HippyRenderBaseView).cssVisibility)
  .zIndex($$.cssZIndex)
  .accessibilityText($$.cssAccessibilityLabel)
  .focusable($$.cssFocusable)
  .border($$.cssBorder)
  .shadow($$.cssShadow)
  .linearGradient($$.cssLinearGradient)
  .backgroundImage($$.cssBackgroundImage)
  .backgroundImageSize($$.cssBackgroundImageSize)
  .backgroundImagePosition($$.cssBackgroundImagePosition)
  .transform($$.cssMatrix)
  .rotate($$.cssRotate)
  .scale($$.cssScale)
  .translate($$.cssTranslate)
  .hitTestBehavior($$.hitTestBehavior)
  .onClick($$.eventClick)
}

