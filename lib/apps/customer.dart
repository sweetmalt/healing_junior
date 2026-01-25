import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/apps/record.dart';
import 'package:healing_junior/ctrl.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';
import 'package:intl/intl.dart';

class CustomerView extends GetView<CustomerCtrl> {
  CustomerView({super.key});
  final myCtrl = Get.put(MyCtrl());
  final employeeCtrl = Get.put(EmployeeCtrl());
  final recordCtrl = Get.put(RecordCtrl());
  final isLoading = false.obs;
  @override
  final controller = Get.put(CustomerCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  initialValue: controller.phone.value,
                  decoration: InputDecoration(
                    labelText: '输入顾客手机号，查询成功后将自动选为服务对象',
                    border: OutlineInputBorder(),
                    suffixIcon: isLoading.value
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.search_rounded),
                            onPressed: () async {
                              if (isLoading.value) {
                                Get.snackbar('正在查询……', '请稍后再试');
                                return;
                              }
                              isLoading.value = true;
                              try {
                                Map<String, dynamic> customer = await employeeCtrl.getCusomer(controller.phone.value);
                                if (customer.isNotEmpty) {
                                  controller.init();
                                  controller.id.value = customer['id'];
                                  controller.nickname.value = customer['nickname'];
                                  controller.phone.value = customer['phone'];
                                  controller.sex.value = customer['sex'] == 0 ? "女" : "男";
                                  controller.birthday.value = DateFormat('yyyy-MM-dd').format(DateTime.parse(customer['birthday']).toLocal());
                                  controller.age.value = Data.calculateAge(DateTime.parse(customer['birthday']));
                                  controller.recordLastAt.value = DateFormat('yyyy-MM-dd').format(DateTime.parse(customer['record_last_at']).toLocal());
                                  controller.isLock.value = customer['is_lock'];
                                  controller.recordings.addAll(customer['recordings']);
                                  controller.isLoaded.value = true;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  recordCtrl.init();
                                }
                              } finally {
                                isLoading.value = false;
                              }
                            },
                          ),
                  ),
                  onChanged: (value) => controller.phone.value = value,
                ),
              ),
              ListTile(
                leading: Icon(Icons.chat_rounded),
                title: Text('顾客昵称: ${controller.nickname.value}'),
              ),
              ListTile(
                leading: Icon(Icons.phone_rounded),
                title: Text('联系电话: ${controller.phone.value}'),
              ),
              ListTile(
                leading: controller.sex.value == '男' ? Icon(Icons.male_rounded) : Icon(Icons.female_rounded),
                title: Text('顾客性别: ${controller.sex.value}'),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month_rounded),
                title: Text('顾客生日: ${controller.birthday.value}'),
              ),
              ListTile(
                leading: Icon(Icons.history_rounded),
                title: Text('顾客年龄: ${controller.age.value}'),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month_rounded),
                title: Text('顾客最近一次到店时间: ${controller.recordLastAt.value}'),
              ),
              ListTile(
                leading: controller.isLock.value ? Icon(Icons.lock_rounded) : Icon(Icons.lock_open_rounded),
                title: Text("服务状态: ${controller.isLock.value ? '已锁定' : '正常'}"),
              ),
              ListTile(
                leading: Icon(Icons.grading_rounded),
                title: Text("检测报告：${recordCtrl.customerRecordFileList.length + controller.recordings.length}份"),
                subtitle: Text("包括：${controller.recordings.length}份云端记录，${recordCtrl.customerRecordFileList.length}份本地记录"),
                onTap: () {
                  if (recordCtrl.customerRecordFileList.isNotEmpty || controller.recordings.isNotEmpty) {
                    Get.to(() => RecordView());
                  }
                },
                trailing: (recordCtrl.customerRecordFileList.isNotEmpty || controller.recordings.isNotEmpty)
                    ? CircularIconButton(
                        icon: Icons.navigate_next_rounded,
                        onPressed: () {
                          if (recordCtrl.customerRecordFileList.isNotEmpty || controller.recordings.isNotEmpty) {
                            Get.to(() => RecordView());
                          }
                        },
                      )
                    : SizedBox.shrink(),
              ),
              if (controller.isLoaded.value)
                ListTile(
                  leading: Icon(Icons.access_time_rounded),
                  title: DropdownButtonFormField<int>(
                    borderRadius: BorderRadius.circular(10),
                    decoration: const InputDecoration(
                      labelText: '选择数据采集时长',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: controller.sampleSize.value,
                    items: [
                      for (int i = 0; i < CustomerCtrl.sample['size'].length; i++)
                        DropdownMenuItem(
                          value: CustomerCtrl.sample['size'][i],
                          child: Text("${CustomerCtrl.sample['sub_title'][i]} / 参考活动：${CustomerCtrl.sample['title'][i]}"),
                        ),
                    ],
                    onChanged: (value) => controller.sampleSize.value = value!,
                  ),
                ),
              const SizedBox(height: 20),
              controller.isLoaded.value
                  ? CircularIconTextButton(
                      text: "开始检测",
                      icon: Icons.insights_rounded,
                      onPressed: () {
                        if (controller.isRecording.value || controller.isRecordingHrv.value) {
                          Get.defaultDialog(
                            title: "提示",
                            middleText: "当前检测未完，确认重新开始检测？",
                            onConfirm: () {
                              myCtrl.clearData();
                              controller.isRecording.value = true;
                              controller.isRecordingHrv.value = true;
                              Get.back();
                            },
                            onCancel: () => Get.back(),
                          );
                        } else {
                          myCtrl.clearData();
                          controller.isRecording.value = true;
                          controller.isRecordingHrv.value = true;
                        }
                      })
                  : Text("请先搜索并添加当前预定服务的顾客"),
              const SizedBox(height: 20),
              if (controller.isRecording.value || controller.isRecordingHrv.value) MyTextH3("检测中……${myCtrl.pureCount.value}，可点击按钮重新开始检测", Colors.red),
              if (controller.isRecording.value || controller.isRecordingHrv.value) CircularProgressIndicator(),
              if (controller.isRecording.value || controller.isRecordingHrv.value)
                ElevatedButton(
                  child: Text("停止检测"),
                  onPressed: () => Get.defaultDialog(
                    title: "提示",
                    middleText: "停止检测将清除已收集数据，确认停止？",
                    onConfirm: () {
                      controller.isRecording.value = false;
                      controller.isRecordingHrv.value = false;
                      myCtrl.clearData();
                      Get.back();
                    },
                    onCancel: () => Get.back(),
                  ),
                ),
              if (controller.isNewSample.value)
                ElevatedButton(
                  child: Text("保存检测"),
                  onPressed: () => Get.defaultDialog(
                    title: "提示",
                    middleText: "确认保存本次检测数据？",
                    onConfirm: () async {
                      controller.sampleData["employee_phone"] = employeeCtrl.phone.value;
                      await controller.saveSampleData();
                      recordCtrl.init();
                      Get.back();
                    },
                    onCancel: () => Get.back(),
                  ),
                ),
            ],
          )),
    );
  }
}

class CustomerCtrl extends GetxController {
  final RxInt id = 0.obs;
  final RxString phone = ''.obs;
  final RxString nickname = '?'.obs;
  final RxString sex = '?'.obs;
  final RxString birthday = '?'.obs;
  final RxInt age = 0.obs;
  final RxString recordLastAt = '?'.obs;
  final RxBool isLock = true.obs;
  final RxList<dynamic> recordings = [].obs;
  final RxBool isLoaded = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isRecordingHrv = false.obs;
  final sampleSize = 128.obs;
  final isNewSample = false.obs;
  final Map<String, dynamic> sampleData = {
    "record_data": {"heartRate": [], "hrv": [], "temperature": [], "delta": [], "theta": [], "alpha": [], "beta": [], "gamma": []},
    "sampleSize": 0,
    "record_id": "",
    "record_at": "",
    "employee_phone": "",
    "record_file": "",
    "is_lock": ""
  };
  static const Map<String, dynamic> sample = {
    "size": [4096, 2048, 1024, 512, 256, 128, 64],
    "title": ["光疗浅睡", "香疗小憩", "音疗正念", "瑜伽( 单人自习、双人互动、群体交流 )", "深呼吸习惯养成训练", "三分钟静息训练", "1分钟快速进入静息状态"],
    "sub_title": ["约80分钟", "约40分钟", "约20分钟", "约10分钟", "约  5分钟", "约  3分钟", "约  1分钟"]
  };
  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() {
    id.value = 0;
    phone.value = '';
    nickname.value = '?';
    sex.value = '?';
    birthday.value = '?';
    age.value = 0;
    recordLastAt.value = '?';
    isLock.value = true;
    recordings.clear();
    isLoaded.value = false;
    isRecording.value = false;
    isRecordingHrv.value = false;
    sampleSize.value = 128;
    isNewSample.value = false;
  }

  void setSampleData(Map<String, dynamic> data) {
    for (var key in data.keys) {
      sampleData["record_data"][key] = data[key];
    }
    isNewSample.value = true;
  }

  Future<void> saveSampleData() async {
    String fileName = "record_${nickname.value}_${phone.value}_${sampleSize.value}_${DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.now())}.json";
    sampleData["record_file"] = fileName;
    sampleData["sampleSize"] = sampleSize.value;
    await Data.write(sampleData, fileName);
    isNewSample.value = false;
  }
}
