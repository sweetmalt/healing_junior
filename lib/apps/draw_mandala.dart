import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';

class DrawMandalaView extends GetView<DrawMandalaCtrl> {
  DrawMandalaView({super.key});

  final isSaving = false.obs;

  @override
  final controller = Get.put(DrawMandalaCtrl());
  @override
  Widget build(BuildContext context) {
    double sideLength = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(10),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // 阴影方向
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 1,
                    children: [
                      MyTextP2("专注度"),
                      MyTextH2("${controller.att.value}"),
                      MyTextP3(DrawMandalaCtrl.qualitative(controller.att.value), colorSurface),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // 阴影方向
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 1,
                    children: [
                      MyTextP2("安全感"),
                      MyTextH2("${controller.med.value}"),
                      MyTextP3(DrawMandalaCtrl.qualitative(controller.med.value), colorSurface),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // 阴影方向
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 1,
                    children: [
                      MyTextP2("松弛感"),
                      MyTextH2("${controller.rel.value}"),
                      MyTextP3(DrawMandalaCtrl.qualitative(controller.rel.value), colorSurface),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // 阴影方向
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 1,
                    children: [
                      MyTextP2("心流感"),
                      MyTextH2("${controller.flu.value}"),
                      MyTextP3(DrawMandalaCtrl.qualitative(controller.flu.value), colorSurface),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // 阴影方向
                      ),
                    ],
                  ),
                  child: Column(
                    spacing: 1,
                    children: [
                      MyTextP2("愉悦感"),
                      MyTextH2("${controller.hap.value}"),
                      MyTextP3(DrawMandalaCtrl.qualitative(controller.hap.value), colorSurface),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            controller.isReady.value
                ? CircularIconTextButton(
                    text: "AI作画",
                    icon: controller.isGettingImage.value ? Icons.refresh_rounded : Icons.camera,
                    onPressed: () async {
                      if (controller.isGettingImage.value) {
                        Get.snackbar("正在作画", "请稍候……");
                        return;
                      }
                      controller.gettingImageTimer.value = 0;
                      controller.isGettingImage.value = true;
                      try {
                        await controller.draw();
                      } finally {
                        controller.isGettingImage.value = false;
                      }
                    },
                  )
                : SizedBox.shrink(),
            if (controller.isGettingImage.value) MyTextP1("正在作画请稍后……${controller.gettingImageTimer.value}"),
            Container(
              alignment: Alignment.center,
              width: sideLength,
              height: sideLength,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1), // 阴影方向
                  ),
                ],
              ),
              child: !controller.isImageExists.value
                  ? Opacity(opacity: 0.1, child: Image.asset("assets/images/brain.png", width: sideLength, height: sideLength))
                  : Image.file(File(controller.imagePath_0.value), width: sideLength, height: sideLength),
            ),
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.center,
              width: sideLength,
              height: sideLength,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1), // 阴影方向
                  ),
                ],
              ),
              child: !controller.isImageExists.value
                  ? Opacity(opacity: 0.1, child: Image.asset("assets/images/brain.png", width: sideLength, height: sideLength))
                  : Image.file(File(controller.imagePath_1.value), width: sideLength, height: sideLength),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawMandalaCtrl extends GetxController {
  static const String cozeBot_0 = "7579177267255935018";//彩色曼荼罗图案
  static const String cozeBot_1 = "7672353909247377446";//曼陀罗图案线稿图
  Timer? _timer;
  final isGettingImage = false.obs;
  final gettingImageTimer = 0.obs;
  final isImageExists = false.obs;

  @override
  void onInit() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (isGettingImage.value) {
        gettingImageTimer.value++;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  final imageUrl_0 = "".obs;
  final imagePath_0 = "".obs;
  final imageUrl_1 = "".obs;
  final imagePath_1 = "".obs;

  final att = 50.obs;
  final med = 50.obs;
  final rel = 50.obs;
  final flu = 50.obs;
  final hap = 50.obs;
  final isReady = false.obs;

  final bearer = "".obs;

  final employeeCtrl = Get.put(EmployeeCtrl());
  final customerCtrl = Get.put(CustomerCtrl());
  void init() {
    imageUrl_0.value = "";
    imagePath_0.value = "";
    imageUrl_1.value = "";
    imagePath_1.value = "";
    att.value = 50;
    med.value = 50;
    rel.value = 50;
    flu.value = 50;
    hap.value = 50;
    isReady.value = false;
    bearer.value = "";
  }

  Future<void> draw() async {
    if (!employeeCtrl.isRegist.value) {
      Get.snackbar("请先登录", "未登录或未联网，无法使用AI功能");
      return;
    }
    //余额不足
    if (employeeCtrl.paymentBalance.value < 3) {
      Get.snackbar("请先充值", "您的账号余额不足，无法使用AI功能");
      return;
    }
    bearer.value = await employeeCtrl.pay(3);
    if (bearer.value.isEmpty) {
      Get.snackbar("异常提示", "获取coze_token失败，请稍后重试");
      return;
    }
    int total = att.value + med.value + rel.value + flu.value + hap.value;
    int hongse = (att.value / total * 100).toInt();
    int chengse = (med.value / total * 100).toInt();
    int lvse = (rel.value / total * 100).toInt();
    int lanse = (flu.value / total * 100).toInt();
    int zise = (hap.value / total * 100).toInt();
    String imagePrompt = "红色$hongse%、橙色$chengse%、绿色$lvse%、蓝色$lanse% 紫色$zise%";
    try {
      isImageExists.value = false;
      imageUrl_0.value = await Data.generateAiImage(cozeBot_0, imagePrompt, bearer.value);
      if (imageUrl_0.value.length > 20) {
        imageUrl_1.value = await Data.generateAiImage(cozeBot_1, imageUrl_0.value, bearer.value);
        if (imageUrl_1.value.length > 20) {
          Get.snackbar("成功", "图片已生成，正在下载到本机，请耐心等候……");
          String sub_0 = imageUrl_0.value.substring(20, imageUrl_0.value.length - 1);
          String sub_1 = imageUrl_1.value.substring(20, imageUrl_1.value.length - 1);
          if (sub_0.isNotEmpty && sub_1.isNotEmpty) {
            String savePath_0 = await Data.path("$sub_0.png");
            String savePath_1 = await Data.path("$sub_1.png");
            if (await Data.downloadAndSaveImage(imageUrl_0.value, savePath_0) && await Data.downloadAndSaveImage(imageUrl_1.value, savePath_1)) {
              imagePath_0.value = savePath_0;
              imagePath_1.value = savePath_1;
              isImageExists.value = true;
              //await save();
              //如果是安卓平台，则保存到相册
              if (Platform.isAndroid) {
                await Data.saveImageToGallery(savePath_0);
                await Data.saveImageToGallery(savePath_1);
              }
            }
          }
        }
      }
    } catch (e) {
      //Get.snackbar("异常提示", "图片生成失败，请稍后重试");
    }
  }

  Future<void> save() async {
    Map<String, dynamic> data = await Data.read("draw_mandala.json");
    data[customerCtrl.phone.value] = {
      "nickname": customerCtrl.nickname.value,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "imageUrl_0": imageUrl_0.value,
      "imagePath_0": imagePath_0.value,
      "imageUrl_1": imageUrl_1.value,
      "imagePath_1": imagePath_1.value,
      "att": att.value,
      "med": med.value,
      "rel": rel.value,
      "flu": flu.value,
      "hap": hap.value,
    };
    await Data.write(data, "draw_mandala.json");
    Get.snackbar("成功", "图片已保存至本软件的自有相册");
  }

  Future<Map<String, dynamic>> read(String phone) async {
    Map<String, dynamic> data = await Data.read("draw_mandala.json");
    if (!data.containsKey(phone)) {
      return {};
    }
    return data[phone];
  }

  //根据数值返回评价
  //75-100 偏高
  //65-74 略高
  //45-64 均衡
  //40-44 略低
  //0-39 偏低
  static String qualitative(int value) {
    if (value >= 75) {
      return "偏高";
    } else if (value >= 65) {
      return "略高";
    } else if (value >= 45) {
      return "均衡";
    } else if (value >= 40) {
      return "略低";
    } else {
      return "偏低";
    }
  }
}
