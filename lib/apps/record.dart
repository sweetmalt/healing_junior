import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';

class RecordView extends GetView<RecordCtrl> {
  RecordView({super.key});
  @override
  final controller = Get.put(RecordCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("记录"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          CircularIconButton(
            icon: Icons.grading_rounded,
            onPressed: () {
              controller.init();
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
                    return RecordList();
                  });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: Record(),
    );
  }
}

class Record extends GetView<RecordCtrl> {
  Record({super.key});
  @override
  final controller = Get.put(RecordCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextP2("${controller.sampleSize.value}"),
                MyTextP2(controller.recordFile.value),
              ],
            )),
      ),
    );
  }
}

class RecordList extends GetView<RecordCtrl> {
  RecordList({super.key});
  @override
  final controller = Get.put(RecordCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                color: colorSecondary,
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
              child: Obx(() => ListView.builder(
                    itemCount: controller.customerRecordFileList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.wallpaper_rounded, color: colorPrimaryContainer),
                        title: Text(controller.customerRecordFileList[index].split("_")[1]),
                        subtitle: Text(controller.customerRecordFileList[index].split("_")[4].split(".")[0]),
                        onTap: () {
                          controller.getLocalRecord(controller.customerRecordFileList[index]);
                          Get.back();
                        },
                      );
                    },
                  )),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.3,
              child: Obx(() => ListView.builder(
                    itemCount: controller.recordFileList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.wallpaper_rounded),
                        title: Text(controller.recordFileList[index].split("_")[1]),
                        subtitle: Text(controller.recordFileList[index].split("_")[4].split(".")[0]),
                        onTap: () {
                          controller.getLocalRecord(controller.recordFileList[index]);
                          Get.back();
                        },
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordCtrl extends GetxController {
  final recordFileList = <String>[].obs;
  final customerRecordFileList = <String>[].obs;
  final customerCtrl = Get.put(CustomerCtrl());

  final heartRate = [].obs;
  final hrv = [].obs;
  final temperature = [].obs;
  final delta = [].obs;
  final theta = [].obs;
  final alpha = [].obs;
  final beta = [].obs;
  final gamma = [].obs;

  final sampleSize = 0.obs;
  final recordId = ''.obs;
  final recordAt = ''.obs;
  final employeePhone = ''.obs;
  final recordFile = ''.obs;
  final isLock = "".obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await init();
  }

  Future<void> init() async {
    recordFileList.value = await Data.readFileList("record_");
    customerRecordFileList.value = recordFileList.where((element) => element.contains(customerCtrl.phone.value)).toList();
    if (customerRecordFileList.isNotEmpty) {
      await getLocalRecord(customerRecordFileList[0]);
    }
  }

  Future<void> getLocalRecord(String fileName) async {
    final data = await Data.read(fileName);
    if (data.isNotEmpty) {
      heartRate.value = data["record_data"]["heartRate"];
      hrv.value = data["record_data"]["hrv"];
      temperature.value = data["record_data"]["temperature"];
      delta.value = data["record_data"]["delta"];
      theta.value = data["record_data"]["theta"];
      alpha.value = data["record_data"]["alpha"];
      beta.value = data["record_data"]["beta"];
      gamma.value = data["record_data"]["gamma"];
      sampleSize.value = data["sampleSize"];
      recordId.value = data["record_id"];
      recordAt.value = data["record_at"];
      employeePhone.value = data["employee_phone"];
      recordFile.value = data["record_file"];
      isLock.value = data["is_lock"];
    }
  }
}
