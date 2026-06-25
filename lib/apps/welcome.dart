import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/index.dart';
import 'package:healing_junior/services/bluetooth.dart';
import 'package:healing_junior/view.dart';

class WelcomeView extends GetView<WelcomeCtrl> {
  final employeeCtrl = Get.put(EmployeeCtrl());
  @override
  final controller = Get.put(WelcomeCtrl());
  final indexCtrl = Get.put(IndexCtrl());
  WelcomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => !employeeCtrl.isRegist.value
                ? ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        useSafeArea: true,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        builder: (context) {
                          return EmployeeView();
                        },
                      );
                    },
                    child: MyTextH1("嗨，请登录"))
                : MyTextH1("嗨，${employeeCtrl.nickname.value}"),
          ),
          MyTextH3("欢迎使用 ${controller.project} 的 ${controller.app} APP", colorPrimaryContainer),
          MyTextP3(controller.title, colorPrimaryContainer),
          ElevatedButton(
            child: Text("设备连接"),
            onPressed: ()=>Get.to(BluetoothAdmin()),
          ),
        ],
      ),
    );
  }
}

class WelcomeCtrl extends GetxController {
  String project = "HealingAI";
  String app = "BrainView";
  String title = "基于 BCI 的非医疗级情绪洞察工具箱";
}


