import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class StepsView extends GetView<StepsCtrl> {
  @override
  final controller = Get.put(StepsCtrl());

  StepsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < controller.steps.length; i++) MyTextP2("Step${i + 1}. ${controller.steps[i]}"),
          ],
        ));
  }
}

class StepsCtrl extends GetxController {
  final List<String> steps = [
    "向顾客解释脑电检测的内容、意义和流程",
    "( 确认管理员已预先录入顾客信息 )",
    "展开检测对象模块，输入顾客手机号搜索并添加顾客",
    "选择检测项目",
    "点击启动检测，并按项目要求引导顾客完成相应活动任务",
    "听到检测完毕提示音，告知顾客检测已完成",
    "向顾客讲解工作区内呈现的各项检测结果",
    "逐一展开想要扫描进入报告的内容模块",
    "点击工具栏上的分享按钮，生成并分享报告给顾客",
  ];
  @override
  Future<void> onInit() async {
    super.onInit();
  }
}
