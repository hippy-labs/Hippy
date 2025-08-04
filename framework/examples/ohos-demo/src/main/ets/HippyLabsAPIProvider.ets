import { HippyAPIProvider } from 'hippy';

import {
  HippyJSModuleCreator, HippyNativeModuleCreator, HRRenderViewCreator
} from 'hippy';
import HippyRenderBaseView
  from 'hippy/src/main/ets/renderer_native/components/base/HippyRenderBaseView'
import { HippyLabsNativeView } from './components/HippyLabsNativeView';

/**
 *  自定义组件和模块入口
 */
export class HippyLabsAPIProvider extends HippyAPIProvider {
  getCustomNativeModuleCreatorMap(): Map<string, HippyNativeModuleCreator> | null {
    let registerMap: Map<string, HippyNativeModuleCreator> = new Map()
    return registerMap;
  }

  getCustomJavaScriptModuleCreatorMap(): Map<string, HippyJSModuleCreator> | null {
    return null
  }

  getCustomRenderViewCreatorMap(): Map<string, HRRenderViewCreator> | null {
    let registerMap: Map<string, HRRenderViewCreator> = new Map()
    //👉 注册组件
    registerMap.set("HippyLabsNativeElement",
      (ctx): HippyRenderBaseView => new HippyLabsNativeView(ctx))
    return registerMap
  }

  getCustomMeasureRenderViews(): Array<string> | null {
    return ["ExampleViewB"]
  }

  getCustomMappingRenderViewMap(): Map<string, string> | null {
    return null
  }
}
