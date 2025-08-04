#pragma once

#include "renderer/arkui/stack_node.h"
#include "renderer/components/custom_view.h"

namespace hippy {
inline namespace render {
inline namespace native {

class HippyLabsView : public CustomView {
  public:
  HippyLabsView(std::shared_ptr<NativeRenderContext> &ctx);
  virtual ~HippyLabsView();

  StackNode *GetLocalRootArkUINode() override;
  void CreateArkUINodeImpl() override;
  void DestroyArkUINodeImpl() override;
  bool SetPropImpl(const std::string &propKey, const HippyValue &propValue) override;

  void OnChildInsertedImpl(std::shared_ptr<BaseView> const &childView, int32_t index) override;
  void OnChildRemovedImpl(std::shared_ptr<BaseView> const &childView, int32_t index) override;

  void CallImpl(const std::string &method, const std::vector<HippyValue> params,
                std::function<void(const HippyValue &result)> callback) override;

  private:
  std::shared_ptr<StackNode> stackNode_;
  std::string message_; // 👈
};

} // namespace native
} // namespace render
} // namespace hippy
