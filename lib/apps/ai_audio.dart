import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/apps/wuluohai.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';
import 'package:just_audio/just_audio.dart';

class AiAudioView extends GetView<AiAudioCtrl> {
  AiAudioView({super.key});

  @override
  final controller = Get.put(AiAudioCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI 音频"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Center(
        child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () async => await controller.create(), child: Text("AI 生成")),
                const SizedBox(height: 20),
                MyTextP3(controller.prompt.value, colorPrimaryContainer),
                const SizedBox(height: 20),
                if (controller.audioUrl.value.isNotEmpty)
                  IconButton(
                      color: colorSurface,
                      iconSize: 128,
                      onPressed: () async {
                        await controller.play();
                      },
                      icon: Icon(controller.isPlaying.value ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded)),
                if (controller.isLoading.value) CircularProgressIndicator(),
              ],
            )),
      ),
    );
  }
}

class AiAudioCtrl extends GetxController {
  static const String cozeBot = "7595915674166476841";
  final audioUrl = "".obs;
  final isPlaying = false.obs;
  final isLoading = false.obs;

  final bearer = "".obs;
  final prompt = "".obs;

  final employeeCtrl = Get.put(EmployeeCtrl());
  final customerCtrl = Get.put(CustomerCtrl());
  final wuluohaiCtrl = Get.put(WuluohaiCtrl());

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> create() async {
    if (isLoading.value) {
      Get.snackbar("提示", "正在生成中，请稍后……");
      return;
    }
    if (!employeeCtrl.isRegist.value) {
      Get.snackbar("请先登录", "未登录或未联网，无法使用AI功能");
      return;
    }
    //余额不足
    if (employeeCtrl.paymentBalance.value < 1) {
      Get.snackbar("请先充值", "您的账号余额不足，无法使用AI功能");
      return;
    }
    if (employeeCtrl.paymentTemp.value < 2) {
      bearer.value = await employeeCtrl.pay(2);
    }
    if (bearer.value.isEmpty) {
      Get.snackbar("异常提示", "网络故障，请稍后重试");
      return;
    }
    prompt.value =
        "疗愈方向：${WuluohaiCtrl.musicTitles.keys.elementAt(wuluohaiCtrl.selectedIndex.value)}：${WuluohaiCtrl.musicTitles.values.elementAt(wuluohaiCtrl.selectedIndex.value)}";
    isLoading.value = true;
    isPlaying.value = false;
    await _audioPlayer.stop();
    audioUrl.value = "";
    try {
      audioUrl.value = await Data.generateAiImage(cozeBot, prompt.value, bearer.value);
      if (audioUrl.value.length > 20) {
        employeeCtrl.paymentTemp.value -= 2;
        isLoading.value = false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> play() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
      isPlaying.value = false;
      return;
    }
    if (audioUrl.value.isEmpty) {
      Get.snackbar("提示", "请先生成音频");
      return;
    }
    await _audioPlayer.setUrl(audioUrl.value);
    await _audioPlayer.setLoopMode(LoopMode.one);
    _audioPlayer.play();
    isPlaying.value = true;
  }
}
