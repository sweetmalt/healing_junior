import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/index.dart';
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
      decoration: BoxDecoration(
        color: colorPrimary,
      ),
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
          // const SizedBox(height: 20),
          // Image.asset("assets/images/brain.png", width: 80, height: 80),
          // const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     indexCtrl.updateIndex(1);
          //   },
          //   child: MyTextP2("立即进入"),
          // ),
        ],
      ),
    );
  }
}

class WelcomeCtrl extends GetxController {
  String project = "HealingAI";
  String app = "Brain View";
  String title = "基于 BCI & HRV 的生命体征洞察工具箱";
}

class FaceView extends GetView<WelcomeCtrl> {
  @override
  final controller = Get.put(WelcomeCtrl());

  FaceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorPrimary,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyTextH3("Welcome to ${controller.project}", colorPrimaryContainer),
        ],
      ),
    );
  }
}
