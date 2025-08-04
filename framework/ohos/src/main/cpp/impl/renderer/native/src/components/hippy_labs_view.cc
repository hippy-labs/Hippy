
#include "renderer/components/hippy_labs_view.h"
#include "footstone/logging.h"
#include "renderer/arkui/arkui_node.h"
#include "renderer/dom_node/hr_node_props.h"
#include "renderer/utils/hr_event_utils.h"
#include "renderer/utils/hr_value_utils.h"

namespace hippy {
inline namespace render {
inline namespace native {

HippyLabsView::HippyLabsView(std::shared_ptr<NativeRenderContext> &ctx) : CustomView(ctx) {}

HippyLabsView::~HippyLabsView() {
  if (!children_.empty()) {
    if (stackNode_) {
      for (const auto &child : children_) {
        stackNode_->RemoveChild(child->GetLocalRootArkUINode());
      }
    }
    children_.clear();
  }
}

StackNode *HippyLabsView::GetLocalRootArkUINode() { return stackNode_.get(); }

void HippyLabsView::CreateArkUINodeImpl() { stackNode_ = std::make_shared<StackNode>(); }

void HippyLabsView::DestroyArkUINodeImpl() { stackNode_ = nullptr; }

/**
 * 👉
 */
bool HippyLabsView::SetPropImpl(const std::string &propKey, const HippyValue &propValue) {
  if (propKey == HRNodeProps::PROP_MESSAGE_PRIORITY) {
    if (!propValue.IsString()) {
      FOOTSTONE_LOG(ERROR) << "Expected string for PROP_MESSAGE_PRIORITY";
      return false;
    }
    message_ = HRValueUtils::GetString(propValue);
    return true;
  }
  return BaseView::SetPropImpl(propKey, propValue);
}

void HippyLabsView::OnChildInsertedImpl(std::shared_ptr<BaseView> const &childView, int32_t index) {
  BaseView::OnChildInsertedImpl(childView, index);
  if (stackNode_) {
    stackNode_->InsertChild(childView->GetLocalRootArkUINode(), index);
  }
}

void HippyLabsView::OnChildRemovedImpl(std::shared_ptr<BaseView> const &childView, int32_t index) {
  BaseView::OnChildRemovedImpl(childView, index);
  stackNode_->RemoveChild(childView->GetLocalRootArkUINode());
}

/**
 * 👉
 */
void HippyLabsView::CallImpl(const std::string &method, const std::vector<HippyValue> params,
                             std::function<void(const HippyValue &result)> callback) {
  FOOTSTONE_DLOG(INFO) << "HippyLabsView call: method " << method << ", params: " << params.size();
  if (method == "sendMessage") {
    auto vueMessage = HRValueUtils::GetString(params[0]);

    //
    std::string nativeMsg = "NativeMsg：我是来自 Native C++ 的消息";
    std::string propMsg = "PropMsg：" + this->message_;
    std::string vueMsg = "VueMsg：" + vueMessage;
    std::string fullMessage = nativeMsg + "\n" + propMsg + "\n" + vueMsg;

    HippyValueObjectType paramsObj;
    paramsObj.insert_or_assign("code", 100);
    paramsObj.insert_or_assign("message", fullMessage);
    std::shared_ptr<HippyValue> retParams = std::make_shared<HippyValue>(paramsObj);
    HREventUtils::SendComponentEvent(ctx_, tag_, HREventUtils::EVENT_NATIVE_EVENT, retParams);
    //
    if (callback) {
      callback(HippyValue("return message from method call"));
    }
  }
  //
  else {
    BaseView::CallImpl(method, params, callback);
  }
}


} // namespace native
} // namespace render
} // namespace hippy
