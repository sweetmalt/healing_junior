import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/services/update_service.dart';
import 'package:healing_junior/view.dart';

class SettingView extends GetView<SettingCtrl> {
  SettingView({super.key});
  @override
  final controller = Get.put(SettingCtrl());

  @override
  Widget build(BuildContext context) {
    final updateService = UpdateService(context);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Obx(() => Column(
              children: [
                const SizedBox(height: 60),
                ElevatedButton(onPressed: () => updateService.checkUpdate(from: "setting"), child: Text('检查 APP 更新')),
                const SizedBox(height: 20),
                MyTextP1("自定义检测页功能模块"),
                const SizedBox(height: 20),
                Divider(height: 1, color: colorSurface),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("脑电图"),
                  value: controller.states[0],
                  onChanged: (value) async {
                    controller.updateState(0, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("基线"),
                  value: controller.states[1],
                  onChanged: (value) async {
                    controller.updateState(1, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("脑波 - δ、θ、α、β、γ"),
                  value: controller.states[2],
                  onChanged: (value) async {
                    controller.updateState(2, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("α波"),
                  value: controller.states[3],
                  onChanged: (value) async {
                    controller.updateState(3, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("β波"),
                  value: controller.states[4],
                  onChanged: (value) async {
                    controller.updateState(4, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("α波 pk β波"),
                  value: controller.states[5],
                  onChanged: (value) async {
                    controller.updateState(5, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("γ波"),
                  value: controller.states[6],
                  onChanged: (value) async {
                    controller.updateState(6, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("γ波 pk β波"),
                  value: controller.states[7],
                  onChanged: (value) async {
                    controller.updateState(7, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("心率 & HRV"),
                  value: controller.states[8],
                  onChanged: (value) async {
                    controller.updateState(8, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("静息率"),
                  value: controller.states[9],
                  onChanged: (value) async {
                    controller.updateState(9, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("大脑负载"),
                  value: controller.states[10],
                  onChanged: (value) async {
                    controller.updateState(10, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("压力指数"),
                  value: controller.states[11],
                  onChanged: (value) async {
                    controller.updateState(11, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("情绪跟踪"),
                  value: controller.states[12],
                  onChanged: (value) async {
                    controller.updateState(12, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("脑波作画"),
                  value: controller.states[13],
                  onChanged: (value) async {
                    controller.updateState(13, value);
                    await controller.save();
                  },
                ),
                Divider(height: 1, color: colorSecondary),
                SwitchListTile(
                  title: const Text("疗愈音乐"),
                  value: controller.states[14],
                  onChanged: (value) async {
                    controller.updateState(14, value);
                    await controller.save();
                  },
                ),
              ],
            )),
      ),
    );
  }
}

class SettingCtrl extends GetxController {
  final RxList<bool> states = List.generate(16, (index) => true).obs;
  @override
  void onInit() async {
    await init();
    super.onInit();
  }

  Future<void> init() async {
    Map<String, dynamic> data = await Data.read("setting.json");
    if (data.isNotEmpty && data["states"] is List && data["states"].length == states.length) {
      states.assignAll(List<bool>.from(data["states"]));
      if (kDebugMode) {
        print(states.toList());
      }
    }
    states.refresh();
  }

  void updateState(int index, bool value) {
    states[index] = value;
    update();
  }

  Future<void> save() async {
    await Data.write({"states": states.toList()}, "setting.json");
  }
}
