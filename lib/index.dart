import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/setting.dart';
import 'package:healing_junior/apps/welcome.dart';
import 'package:healing_junior/services/update_service.dart';
import 'package:healing_junior/view.dart';

class IndexView extends GetView<IndexCtrl> {
  IndexView({super.key});
  @override
  final IndexCtrl controller = Get.put(IndexCtrl());
  @override
  Widget build(BuildContext context) {
    UpdateService(context).checkUpdate();
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.index.value,
        children: [
          WelcomeView(),
          MyView(),
          SettingView(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.index.value,
        onTap: controller.updateIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.child_care_rounded), label: '欢迎'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: '检测'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      )),
    );
  }
}

class IndexCtrl extends GetxController {
  final RxInt index = 0.obs;
  void updateIndex(int value) {
    index.value = value;
    update();
  }
}