<template>
  <div id="root">
    <hippy-labs-view
      ref="viewRef"
      class="hippy-labs-view-css"
      message="我是来自 Props 的消息"
      @msg-event="onMsgEvent">
      <p class="hippy-labs-child-view-css">返回码：{{ code }}</p>
      <p class="hippy-labs-child-view-css">消息内容：{{ msg }}</p>
      <p class="hippy-labs-child-view-css">回调消息：{{ retMsg }}</p>
    </hippy-labs-view>
  </div>
</template>
<script lang="ts">
import {defineComponent, onMounted, ref} from '@vue/runtime-core';
import HippyLabsComponent from "./components/HippyLabsComponent";

export default defineComponent({
  name: 'App',
  components: {HippyLabsComponent},
  setup() {
    const code = ref<string>("")
    const msg = ref<string>("")
    const retMsg = ref<string>("")

    const viewRef = ref()


    onMounted(() => {
      setTimeout(() => {
        viewRef.value?.sendMessage("我是来自 Vue 的消息").then(msg => {
          retMsg.value = msg
        }, error => {
          console.log(error)
        })
      }, 3000)
    })

    function onMsgEvent(evt) {
      msg.value = evt.message
      code.value = `${evt.code}`
    }

    return {
      viewRef,
      onMsgEvent,
      retMsg,
      msg,
      code
    };
  },
});
</script>
<style>
#root {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #40b883;
}

.hippy-labs-view-css {
  width: 500px;
  height: 500px;
  background-color: palevioletred;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.hippy-labs-child-view-css {
  width: 450px;
  height: 100px;
  background-color: purple;
  margin: 10px;
  text-align: center;
  color: white;
}

</style>
