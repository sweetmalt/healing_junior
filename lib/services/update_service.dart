import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart' as semver;
import 'package:url_launcher/url_launcher.dart';

class UpdateService extends GetxController {
  final BuildContext context;
  UpdateService(this.context);

  Future<void> checkUpdate({String from = ""}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final response = await http.get(Uri.parse('${Data.srvIp}version/'));
    if (kDebugMode) {
      print(response.body);
    }

    if (response.statusCode == 200) {
      final remoteVersion = semver.Version.parse(jsonDecode(response.body)['latest_version']);
      final localVersion = semver.Version.parse(packageInfo.version);

      if (remoteVersion > localVersion) {
        showUpdateDialog(forceUpdate: jsonDecode(response.body)['force_update'], downloadUrl: jsonDecode(response.body)['download_url']);
      } else {
        if (from == "setting") {
          Get.snackbar('提示', '当前版本为最新版本');
        }
      }
    }
  }

  void showUpdateDialog({required bool forceUpdate, required String downloadUrl}) {
    showDialog(
        barrierDismissible: !forceUpdate,
        context: context,
        builder: (ctx) => AlertDialog(title: Text('发现新版本'), actions: [
              if (!forceUpdate) TextButton(onPressed: () => Navigator.pop(ctx), child: Text('稍后')),
              TextButton(onPressed: () => launchUrl(Uri.parse(downloadUrl)), child: Text('立即更新'))
            ]));
  }
}
