import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/face.dart';
import 'package:healing_junior/apps/setting.dart';
import 'package:healing_junior/view.dart';

class IndexView extends GetView<IndexCtrl> {
  IndexView({super.key});
  @override
  final IndexCtrl controller = Get.put(IndexCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.index.value,
            children: [
              FaceView(),
              MyView(),
              SettingView(),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            selectedFontSize: 16,
            currentIndex: controller.index.value,
            onTap: controller.updateIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.child_care_rounded), label: '欢迎'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: '检测'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            'AI对话',
            '功能开发中',
            messageText: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              child: Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < controller.talkList.length; i++) ElevatedButton(onPressed: () {}, child: Text(controller.talkList[i])),
                    ],
                  )),
            ),
            duration: const Duration(seconds: 600),
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Icon(Icons.messenger_rounded),
      ),
    );
  }
}

class IndexCtrl extends GetxController {
  final index = 0.obs;
  void updateIndex(int value) {
    index.value = value;
  }

  final talkList = ["您好！", "此刻，您看到了什么？", "让您想起啥？"].obs;
  void updateTalk(String talk) {
    String subTalk = "";
    if (talk.length > 20) {
      subTalk = "${talk.substring(0, 20)}...";
    } else {
      subTalk = talk;
    }
    talkList[0] = talkList[1];
    talkList[1] = talkList[2];
    talkList[2] = subTalk;
  }
}
