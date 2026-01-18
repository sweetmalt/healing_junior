import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';
import 'package:http/http.dart' as http;

class EmployeeView extends GetView<EmployeeCtrl> {
  EmployeeView({super.key});
  final RxBool isLogin = false.obs;
  @override
  final controller = Get.put(EmployeeCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        title: const Text("我的"),
        backgroundColor: colorSecondary,
      ),
      body: SingleChildScrollView(
        child: Obx(() => Column(
              children: [
                const SizedBox(height: 1),
                ExpansionTile(
                  initiallyExpanded: controller.isRegist.value,
                  collapsedBackgroundColor: colorSecondary,
                  title: MyTextP1('个人信息'),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                  collapsedShape: Border(top: BorderSide(color: colorSurface)),
                  shape: Border(top: BorderSide(color: colorSurface)),
                  children: [
                    ListTile(
                      title: Text('我的余额：${controller.paymentBalance.value}'),
                    ),
                    ListTile(
                      title: Text('消费总额：${controller.totalConsumed.value}'),
                    ),
                    ListTile(
                      title: Text('应用状态：${controller.isLock.value ? "已锁定" : "正常"}'),
                    ),
                    ListTile(
                      title: Text('我的昵称：${controller.nickname.value}'),
                    ),
                    ListTile(
                      title: Text('联系电话：${controller.phone.value}'),
                    ),
                    ExpansionTile(
                      title: const Text('我要登录/重新登录'),
                      initiallyExpanded: false,
                      collapsedBackgroundColor: colorSurface,
                      backgroundColor: colorSecondary,
                      collapsedTextColor: colorPrimaryContainer,
                      textColor: colorPrimaryContainer,
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                      collapsedShape: Border(top: BorderSide(color: colorSurface)),
                      shape: Border(top: BorderSide(color: colorSurface)),
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          decoration: const InputDecoration(
                            labelText: '手机号',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: controller.phone.value,
                          onChanged: (value) => controller.phone.value = value,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: const InputDecoration(
                            labelText: '密码',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: controller.password.value,
                          onChanged: (value) => controller.password.value = value,
                        ),
                        const SizedBox(height: 20),
                        Text(controller.isRegist.value ? '已登录，可重新登录' : '未登录，请输入您的手机号和密码并点击登录'),
                        const SizedBox(height: 20),
                        isLogin.value
                            ? CircularProgressIndicator()
                            : CircularIconTextButton(
                                text: "登录",
                                icon: Icons.login_rounded,
                                onPressed: () async {
                                  if (isLogin.value) {
                                    Get.snackbar('登录中……', '请先稍候');
                                    return;
                                  }
                                  if (controller.phone.value.length != 11 || controller.password.value.length != 8) {
                                    Get.snackbar('输入错误', '手机号为11位数字，密码为8位字符');
                                    return;
                                  }
                                  isLogin.value = true;
                                  try {
                                    if (await controller.login()) {
                                      Get.snackbar('登录成功', '服务者登录成功');
                                    } else {
                                      Get.snackbar('登录失败', '手机号未注册或密码错误');
                                    }
                                  } finally {
                                    isLogin.value = false;
                                  }
                                },
                              ),
                        const SizedBox(height: 40),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (controller.isRegist.value) CircularIconTextButton(text: "注销", icon: Icons.logout_rounded, onPressed: () => controller.logOut(context)),
                    const SizedBox(height: 20),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            )),
      ),
    );
  }
}

class EmployeeCtrl extends GetxController {
  RxInt id = 0.obs;
  RxString phone = ''.obs;
  RxString password = '88888888'.obs;
  RxString nickname = ''.obs;
  RxDouble paymentBalance = 0.0.obs;
  RxDouble totalConsumed = 0.0.obs;
  RxBool isLock = true.obs;
  RxBool isRegist = false.obs;
  RxDouble paymentTemp = 0.0.obs;
  @override
  Future<void> onInit() async {
    Map<String, dynamic> employee = await Data.read('employee.json');
    if (employee.isNotEmpty) {
      phone.value = employee['phone'];
      password.value = employee['password'];
      id.value = employee['id'];
      nickname.value = employee['nickname'];
      paymentBalance.value = employee['payment_balance'];
      totalConsumed.value = employee['total_consumed'];
      isLock.value = employee['is_lock'];
      isRegist.value = true;
    }
    super.onInit();
  }

  Future<void> logOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出服务者登录'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('您确定要执行此操作吗？'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                isRegist.value = false;
                id.value = 0;
                phone.value = '';
                password.value = '88888888';
                nickname.value = '';
                paymentBalance.value = 0.0;
                totalConsumed.value = 0.0;
                isLock.value = true;
                Data.write({}, 'employee.json');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> login() async {
    if (phone.value.isEmpty || password.value.isEmpty) {
      return false;
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}employee/'),
          body: jsonEncode({
            'phone': phone.value,
            'password': password.value,
          }));
    } catch (e) {
      if (kDebugMode) {
        print("异常Login $e");
      }
    }
    if (response == null || response.statusCode != 200) {
      return false;
    } else {
      final responseData = json.decode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      // 更新数据
      id.value = responseData['id'];
      nickname.value = responseData['nickname'];
      paymentBalance.value = double.parse(responseData['payment_balance']);
      totalConsumed.value = double.parse(responseData['total_consumed']);
      isLock.value = responseData['is_lock'];
      // 保存到本地
      await Data.write({
        "phone": phone.value,
        "password": password.value,
        "id": id.value,
        "nickname": nickname.value,
        "payment_balance": paymentBalance.value,
        "total_consumed": totalConsumed.value,
        "is_lock": isLock.value,
      }, 'employee.json');
      isRegist.value = true;
      return true;
    }
  }

  Future<Map<String, dynamic>> getCusomer(String customerPhone) async {
    if (phone.value.isEmpty || password.value.isEmpty || customerPhone.isEmpty) {
      return {};
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}employee/customer/'),
          body: jsonEncode({
            'phone': phone.value,
            'password': password.value,
            'customer_phone': customerPhone,
          }));
    } catch (e) {
      if (kDebugMode) {
        print("异常getCusomer $e");
      }
      return {};
    }
    if (response.statusCode != 200) {
      return {};
    } else {
      final responseData = json.decode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      return responseData;
    }
  }

  Future<String> pay(double amount) async {
    if (phone.value.isEmpty || password.value.isEmpty) {
      return "";
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}employee/pay/'),
          body: jsonEncode({
            'phone': phone.value,
            'password': password.value,
            'amount': amount,
          }));
    } catch (e) {
      if (kDebugMode) {
        print("异常pay $e");
      }
    }
    if (response == null || response.statusCode != 200) {
      return "";
    } else {
      final responseData = json.decode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      // 更新数据
      paymentBalance.value = double.parse(responseData['payment_balance']);
      totalConsumed.value = double.parse(responseData['total_consumed']);
      // 保存到本地
      await Data.write({
        "phone": phone.value,
        "password": password.value,
        "id": id.value,
        "nickname": nickname.value,
        "payment_balance": paymentBalance.value,
        "total_consumed": totalConsumed.value,
        "is_lock": isLock.value,
      }, 'employee.json');
      paymentTemp.value += amount;
      return responseData['coze_token'];
    }
  }
}
