// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:healing_junior/data.dart';
// import 'package:http/http.dart' as http;

// class User {
//   final id = 0.obs;
//   final agencyName = "".obs;
//   final tokens = 0.obs;
//   final registTimestamp = "".obs;
//   final lastLoginTimestamp = "".obs;
//   final adminNickname = "".obs;
//   final adminPhonenumber = "".obs;
//   final adminPassword = "".obs;
//   final adminAddress = "".obs;
//   final vip = 0.obs; //0普通用户(无法生成报告)，1vip用户(生成报告需扣分)，2vip(生成报告不扣分)
//   final bearer = "".obs;
//   final loginState = 0.obs; //0未登录，1登录中，2登录成功
//   final useTokens = 0.obs;
//   final usingTokens = 0.obs;
//   final customer = Customer();
//   User();

//   Future<void> init() async {
//     final Map<String, dynamic> user = await Data.read("user.json");
//     if (user.isNotEmpty) {
//       usingTokens.value = user["using_tokens"] ?? 0;
//       adminPhonenumber.value = user["admin_phonenumber"] ?? "";
//       adminPassword.value = user["admin_password"] ?? "";
//       await login();
//     }
//   }

//   Future<void> cache() async {
//     final Map<String, dynamic> user = {
//       "id": id.value,
//       "agency_name": agencyName.value,
//       "tokens": tokens.value,
//       "regist_timestamp": registTimestamp.value,
//       "last_login_timestamp": lastLoginTimestamp.value,
//       "admin_nickname": adminNickname.value,
//       "admin_phonenumber": adminPhonenumber.value,
//       "admin_password": adminPassword.value,
//       "admin_address": adminAddress.value,
//       "vip": vip.value,
//       "bearer": bearer.value,
//       "use_tokens": useTokens.value,
//       "using_tokens": usingTokens.value,
//     };
//     await Data.write(user, "user.json");
//   }

//   bool _validateUserData(Map<String, dynamic> data) {
//     const requiredKeys = ['id', 'agency_name', 'bearer'];
//     return requiredKeys.every(data.containsKey);
//   }

//   Future<void> login() async {
//     if (adminPhonenumber.value == "" || adminPassword.value == "") {
//       loginState.value = 0;
//       return;
//     }
//     loginState.value = 1;
//     var response = await http.post(
//       Uri.parse('https://ur.healingai.top/api/login.php'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'admin_phonenumber': adminPhonenumber.value,
//         'admin_password': adminPassword.value,
//       }),
//     );
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final Map<String, dynamic> user = responseData['user'];
//       if (!_validateUserData(user)) {
//         loginState.value = 0;
//         return;
//       }
//       id.value = user["id"];
//       agencyName.value = user["agency_name"];
//       tokens.value = user["tokens"];
//       registTimestamp.value = user["regist_timestamp"];
//       lastLoginTimestamp.value = user["last_login_timestamp"];
//       adminNickname.value = user["admin_nickname"];
//       adminAddress.value = user["admin_address"];
//       vip.value = user["vip"];
//       bearer.value = user['bearer'];
//       useTokens.value = user["use_tokens"];
//       await cache();
//       loginState.value = 2;
//     } else {
//       loginState.value = 0;
//     }
//   }

//   Future<bool> useOneToken() async {
//     var response = await http.post(
//       Uri.parse('https://ur.healingai.top/api/use_one_token.php'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'admin_phonenumber': adminPhonenumber.value,
//         'admin_password': adminPassword.value,
//       }),
//     );
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final Map<String, dynamic> user = responseData['user'];
//       bearer.value = user['bearer'];
//       tokens.value = user["tokens"];
//       useTokens.value = user["use_tokens"];
//       usingTokens.value += 1;
//       await cache();
//       return true;
//     } else {
//       return false;
//     }
//   }

//   Future<void> regist(
//     String agencyName_,
//     String adminNickname_,
//     String adminPhonenumber_,
//     String adminPassword_,
//     String adminAddress_,
//   ) async {
//     loginState.value = 1;
//     var response = await http.post(
//       Uri.parse('https://ur.healingai.top/api/register.php'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'agency_name': agencyName_,
//         'admin_nickname': adminNickname_,
//         'admin_phonenumber': adminPhonenumber_,
//         'admin_password': adminPassword_,
//         'admin_address': adminAddress_,
//       }),
//     );
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final Map<String, dynamic> user = responseData['user'];
//       id.value = user['id'];
//       agencyName.value = agencyName_;
//       tokens.value = user['tokens'];
//       registTimestamp.value = user["regist_timestamp"];
//       lastLoginTimestamp.value = user["last_login_timestamp"];
//       adminNickname.value = adminNickname_;
//       adminPhonenumber.value = adminPhonenumber_;
//       adminPassword.value = adminPassword_;
//       adminAddress.value = adminAddress_;
//       vip.value = user["vip"];
//       bearer.value = user['bearer'];
//       await cache();
//       loginState.value = 2;
//     } else {
//       loginState.value = 0;
//     }
//   }

//   Future<void> updateAgencyName() async {}

//   Future<void> updateAdminInfo() async {}

//   Future<void> updateAdminPassword() async {}
// }

// class Customer {
//   final RxInt id = 0.obs;
//   final RxString nickname = "".obs;
//   final RxString birthday = "2008-08-08".obs;
//   final RxInt age = 18.obs;
//   final RxInt sex = 1.obs; //0:男 1:女
//   Map<String, dynamic> customerList = {};
//   Customer();
//   Future<void> init() async {
//     customerList = await Data.read("customer.json");
//   }

// // 添加客户
//   Future<void> add() async {
//     if (nickname.value.isEmpty || customerList.containsKey(nickname.value)) {
//       return;
//     }
//     customerList[nickname.value] = {
//       "id": id.value,
//       "nickname": nickname.value,
//       "birthday": birthday.value,
//       "sex": sex.value,
//     };
//     await cache();
//   }

//   // 删除客户
//   Future<void> delete() async {
//     if (nickname.value.isEmpty || !customerList.containsKey(nickname.value)) {
//       return;
//     }
//     customerList.remove(nickname.value);
//     await cache();
//   }

//   // 更新客户信息
//   Future<void> update() async {
//     if (nickname.value.isEmpty || !customerList.containsKey(nickname.value)) {
//       return;
//     }
//     customerList[nickname.value] = {
//       "id": id.value,
//       "nickname": nickname.value,
//       "birthday": birthday.value,
//       "sex": sex.value,
//     };
//     await cache();
//   }

//   // 获取客户信息
//   Future<bool> get(String nickname_) async {
//     if (nickname_.isEmpty || !customerList.containsKey(nickname_)) {
//       return false;
//     }
//     id.value = customerList[nickname_]["id"];
//     nickname.value = customerList[nickname_]["nickname"];
//     birthday.value = customerList[nickname_]["birthday"];
//     age.value = calculateAge(birthday.value);
//     sex.value = customerList[nickname_]["sex"];
//     return true;
//   }

//   // 计算年龄
//   int calculateAge(String birthday) {
//     final DateTime birthDate = DateTime.parse(birthday);
//     final DateTime currentDate = DateTime.now();
//     int age = currentDate.year - birthDate.year;
//     if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
//       age--;
//     }
//     return age;
//   }

//   Future<void> cache() async {
//     await Data.write(customerList, "customer.json");
//   }
// }

// class ApiService {
//   static final _client = http.Client();

//   static Future<Map<String, dynamic>> post(String endpoint, dynamic body) async {
//     final response = await _client.post(Uri.parse('https://ur.healingai.top/api/$endpoint'),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(body));
//     return json.decode(response.body);
//   }
// }
