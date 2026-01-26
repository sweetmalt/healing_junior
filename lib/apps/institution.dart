import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InstitutionView extends GetView<InstitutionCtrl> {
  InstitutionView({super.key});
  final RxBool isLogin = false.obs;
  final RxBool isGetEmployees = false.obs;
  final RxBool isGetCustomers = false.obs;
  final Map<String, dynamic> newCustomer = {
    'phone': '',
    'password': '88888888',
    'nickname': '',
    'sex': 0,
    'birthday': DateTime.now(),
  };
  final RxString selectedDate = ''.obs;
  final RxBool isNewCustomer = false.obs;
  @override
  final controller = Get.put(InstitutionCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        title: const Text("我的组织"),
        backgroundColor: colorSecondary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(() => Column(
              children: [
                const SizedBox(height: 1),
                ExpansionTile(
                  initiallyExpanded: controller.isRegist.value,
                  collapsedBackgroundColor: colorSecondary,
                  title: MyTextP1('我的机构'),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                  collapsedShape: Border(top: BorderSide(color: colorSurface)),
                  shape: Border(top: BorderSide(color: colorSurface)),
                  children: [
                    ListTile(
                      title: Text('机构全称：${controller.fullName.value}'),
                    ),
                    ListTile(
                      title: Text('机构简称：${controller.shortName.value}'),
                    ),
                    ListTile(
                      title: Text('联系地址：${controller.address.value}'),
                    ),
                    ListTile(
                      title: Text('消费总额：${controller.totalConsumed.value}'),
                    ),
                    ListTile(
                      title: Text('机构状态：${controller.isLock.value ? "已锁定" : "正常"}'),
                    ),
                    ListTile(
                      title: Text('管理昵称：${controller.nickname.value}'),
                    ),
                    ListTile(
                      title: Text('联系电话：${controller.phone.value}'),
                    ),
                    ExpansionTile(
                      title: const Text('管理员登录/重新登录'),
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
                        Text(controller.isRegist.value ? '已登录，可重新登录' : '未登录，请输入机构管理员的手机号和密码并点击登录'),
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
                                      Get.snackbar('登录成功', '机构登录成功');
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
                    controller.isRegist.value
                        ? CircularIconTextButton(
                            text: "注销",
                            icon: Icons.logout_rounded,
                            onPressed: () async {
                              await controller.logOut(context);
                              Get.snackbar('注销成功', '机构已注销');
                            })
                        : const SizedBox.shrink(),
                    const SizedBox(height: 20),
                  ],
                ),
                const SizedBox(height: 1),
                if (controller.isRegist.value)
                  ExpansionTile(
                    initiallyExpanded: controller.isRegist.value,
                    collapsedBackgroundColor: colorSecondary,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1('我的客服'),
                    children: [
                      CircularIconTextButton(
                          text: "刷新",
                          icon: Icons.refresh_rounded,
                          onPressed: () async {
                            if (isGetEmployees.value) {
                              Get.snackbar('刷新中……', '请先稍候');
                              return;
                            }
                            isGetEmployees.value = true;
                            try {
                              if (await controller.getEmployees()) {
                                Get.snackbar('刷新成功', '员工列表已刷新');
                              } else {
                                Get.snackbar('刷新失败', '请检查网络连接');
                              }
                            } finally {
                              isGetEmployees.value = false;
                            }
                          }),
                      const SizedBox(height: 40),
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: FixedColumnWidth(100),
                          1: FixedColumnWidth(150),
                          2: FixedColumnWidth(100),
                          3: FixedColumnWidth(100),
                          4: FixedColumnWidth(50),
                        },
                        border: TableBorder.all(color: colorSurface, width: 1, borderRadius: BorderRadius.circular(5)),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: colorSurface),
                            children: [
                              MyTextP2("客服昵称"),
                              MyTextP2("手机号"),
                              MyTextP2("账户余额"),
                              MyTextP2("已消费"),
                              MyTextP2("状态"),
                            ],
                          ),
                          for (var employee in controller.employees)
                            TableRow(
                              children: [
                                MyTextP2('${employee['nickname']}'),
                                MyTextP2('${employee['phone']}'),
                                MyTextP2('${employee['payment_balance']}'),
                                MyTextP2('${employee['total_consumed']}'),
                                MyTextP2(employee['is_lock'] ? '已锁定' : '正常'),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                const SizedBox(height: 1),
                if (controller.isRegist.value)
                  ExpansionTile(
                    initiallyExpanded: controller.isRegist.value,
                    collapsedBackgroundColor: colorSecondary,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1('我的顾客'),
                    children: [
                      CircularIconTextButton(
                          text: "刷新",
                          icon: Icons.refresh_rounded,
                          onPressed: () async {
                            if (isGetCustomers.value) {
                              Get.snackbar('刷新中……', '请先稍候');
                              return;
                            }
                            isGetCustomers.value = true;
                            try {
                              if (await controller.getCustomers()) {
                                Get.snackbar('刷新成功', '顾客列表已刷新');
                              } else {
                                Get.snackbar('刷新失败', '请检查网络连接');
                              }
                            } finally {
                              isGetCustomers.value = false;
                            }
                          }),
                      const SizedBox(height: 40),
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: FixedColumnWidth(100),
                          1: FixedColumnWidth(120),
                          2: FixedColumnWidth(40),
                          3: FixedColumnWidth(100),
                          4: FixedColumnWidth(40),
                          5: FixedColumnWidth(100),
                          6: FixedColumnWidth(50),
                        },
                        border: TableBorder.all(color: colorSurface, width: 1, borderRadius: BorderRadius.circular(5)),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: colorSurface),
                            children: [
                              MyTextP2("顾客昵称"),
                              MyTextP2("手机号"),
                              MyTextP2("性别"),
                              MyTextP2("生日"),
                              MyTextP2("年龄"),
                              MyTextP2("最近到店日期"),
                              MyTextP2("状态"),
                            ],
                          ),
                          for (var customer in controller.customers)
                            TableRow(
                              children: [
                                MyTextP2('${customer['nickname']}'),
                                MyTextP2('${customer['phone']}'),
                                MyTextP2(customer['sex'] == 0 ? '女' : '男'),
                                MyTextP2(DateFormat('yyyy-MM-dd').format(DateTime.parse(customer['birthday']))),
                                MyTextP2('${Data.calculateAge(DateTime.parse(customer['birthday']))}'),
                                MyTextP2(DateFormat('yyyy-MM-dd').format(DateTime.parse(customer['record_last_at']))),
                                MyTextP2(customer['is_lock'] ? '已锁定' : '正常'),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      if (controller.isRegist.value)
                        ExpansionTile(
                          title: const Text('添加新顾客'),
                          initiallyExpanded: false,
                          collapsedBackgroundColor: colorSurface,
                          backgroundColor: colorSecondary,
                          collapsedTextColor: colorPrimaryContainer,
                          textColor: colorPrimaryContainer,
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
                          collapsedShape: Border(top: BorderSide(color: colorSurface)),
                          shape: Border(top: BorderSide(color: colorSurface)),
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 11,
                              decoration: const InputDecoration(
                                labelText: '手机号',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: newCustomer['phone'],
                              onChanged: (value) => newCustomer['phone'] = value,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              decoration: const InputDecoration(
                                labelText: '密码',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: newCustomer['password'],
                              onChanged: (value) => newCustomer['password'] = value,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: '昵称',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: newCustomer['nickname'],
                              onChanged: (value) => newCustomer['nickname'] = value,
                            ),
                            const SizedBox(height: 10),
                            //性别选择
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: '性别',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: newCustomer['sex'],
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('女')),
                                DropdownMenuItem(value: 1, child: Text('男')),
                              ],
                              onChanged: (value) => newCustomer['sex'] = value!,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '生日',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: newCustomer['birthday'] ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (selected != null) {
                                  newCustomer['birthday'] = DateTime(selected.year, selected.month, selected.day, 12);
                                  selectedDate.value = DateFormat('yyyy-MM-dd').format(selected);
                                }
                              },
                              controller: TextEditingController(
                                text: selectedDate.value,
                              ),
                            ),
                            const SizedBox(height: 20),
                            isNewCustomer.value
                                ? CircularProgressIndicator()
                                : CircularIconTextButton(
                                    text: "添加",
                                    icon: Icons.add_rounded,
                                    onPressed: () async {
                                      if (isNewCustomer.value) {
                                        Get.snackbar('新顾客添加中……', '请稍候');
                                        return;
                                      }
                                      if (newCustomer['phone'].length != 11 ||
                                          newCustomer['password'].length != 8 ||
                                          newCustomer['nickname'].isEmpty ||
                                          ![0, 1].contains(newCustomer['sex'])) {
                                        Get.snackbar('输入错误', '手机号为11位数字，密码为8位字符，昵称不能为空，性别必须为0或1');
                                        return;
                                      }
                                      if (newCustomer['nickname'].contains('_')) {
                                        Get.snackbar('输入错误', '昵称不能包含下划线');
                                        return;
                                      }
                                      //手机号是否可用
                                      if (!controller.isRightCustomerPhone(newCustomer['phone'])) {
                                        Get.snackbar('手机号已被占用', '请使用其他手机号');
                                        return;
                                      }
                                      isNewCustomer.value = true;
                                      try {
                                        if (await controller.addCustomer(newCustomer)) {
                                          Get.snackbar('添加成功', '顾客添加成功');
                                          newCustomer["phone"] = "";
                                          newCustomer["password"] = "88888888";
                                          newCustomer["nickname"] = "";
                                          newCustomer["sex"] = 0;
                                          newCustomer["birthday"] = DateTime.now();
                                        } else {
                                          Get.snackbar('添加失败', '手机号可能已在另一家机构里注册过');
                                        }
                                      } finally {
                                        isNewCustomer.value = false;
                                      }
                                    },
                                  ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                const SizedBox(height: 40),
              ],
            )),
      ),
    );
  }
}

class InstitutionCtrl extends GetxController {
  RxInt id = 0.obs;
  RxString fullName = ''.obs;
  RxString shortName = ''.obs;
  RxString address = ''.obs;
  RxString phone = ''.obs;
  RxString password = '88888888'.obs;
  RxString nickname = ''.obs;
  RxDouble totalConsumed = 0.0.obs;
  RxBool isLock = true.obs;
  RxBool isRegist = false.obs;

  RxList<dynamic> employees = [].obs;
  RxList<dynamic> customers = [].obs;

  @override
  Future<void> onInit() async {
    Map<String, dynamic> institution = await Data.read('institution.json');
    if (institution.isNotEmpty) {
      phone.value = institution['phone'];
      password.value = institution['password'];
      id.value = institution['id'];
      fullName.value = institution['full_name'];
      shortName.value = institution['short_name'];
      address.value = institution['address'];
      nickname.value = institution['nickname'];
      totalConsumed.value = institution['total_consumed'];
      isLock.value = institution['is_lock'];
      isRegist.value = true;
      await getEmployees();
      await getCustomers();
    }
    super.onInit();
  }

  Future<void> logOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出机构登录'),
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
                fullName.value = '';
                shortName.value = '';
                address.value = '';
                phone.value = '';
                password.value = '88888888';
                nickname.value = '';
                totalConsumed.value = 0.0;
                isLock.value = true;
                employees.clear();
                customers.clear();

                Data.write({}, 'institution.json');
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
      response = await http.post(Uri.parse('${Data.srvIp}institution/'),
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
      fullName.value = responseData['full_name'];
      shortName.value = responseData['short_name'];
      address.value = responseData['address'];
      nickname.value = responseData['nickname'];
      totalConsumed.value = double.parse(responseData['total_consumed']);
      isLock.value = responseData['is_lock'];
      // 保存到本地
      await Data.write({
        "phone": phone.value,
        "password": password.value,
        "id": id.value,
        "full_name": fullName.value,
        "short_name": shortName.value,
        "address": address.value,
        "nickname": nickname.value,
        "total_consumed": totalConsumed.value,
        "is_lock": isLock.value,
      }, 'institution.json');
      isRegist.value = true;
      await getEmployees();
      await getCustomers();
      return true;
    }
  }

  Future<bool> getEmployees() async {
    if (phone.value.isEmpty || password.value.isEmpty) {
      return false;
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}institution/employees/'),
          body: jsonEncode({
            'phone': phone.value,
            'password': password.value,
          }));
    } catch (e) {
      if (kDebugMode) {
        print("异常GetEmployees $e");
      }
    }
    if (response == null || response.statusCode != 200) {
      return false;
    } else {
      final responseData = json.decode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      employees.clear();
      employees.addAll(responseData);
      return true;
    }
  }

  Future<bool> getCustomers() async {
    if (phone.value.isEmpty || password.value.isEmpty) {
      return false;
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}institution/customers/'),
          body: jsonEncode({
            'phone': phone.value,
            'password': password.value,
          }));
    } catch (e) {
      if (kDebugMode) {
        print("异常GetCustomers $e");
      }
    }
    if (response == null || response.statusCode != 200) {
      return false;
    } else {
      final responseData = json.decode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      customers.clear();
      customers.addAll(responseData);
      return true;
    }
  }

  Future<bool> addCustomer(Map<String, dynamic> newCustomer) async {
    if (phone.value.isEmpty || password.value.isEmpty) {
      return false;
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}institution/customer/add/'),
          body: jsonEncode({
            'phone': phone.value,
            'password': password.value,
            'customer_phone': newCustomer['phone'],
            'customer_password': newCustomer['password'],
            'customer_nickname': newCustomer['nickname'],
            'customer_sex': newCustomer['sex'],
            'customer_birthday': newCustomer['birthday'].toIso8601String(), //Type: DateTime
          }));
    } catch (e) {
      if (kDebugMode) {
        print("异常AddCustomer $e");
      }
    }
    if (response == null || response.statusCode != 200) {
      return false;
    } else {
      final responseData = json.decode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      customers.add(responseData);
      return true;
    }
  }

  bool isRightCustomerPhone(String phone) {
    if (phone.length != 11) {
      return false;
    }
    for (var customer in customers) {
      if (customer['phone'] == phone) {
        return false;
      }
    }
    return true;
  }
}
