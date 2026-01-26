import 'dart:convert';
import 'dart:io';

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
  String _getPlatform() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    }
    return 'unknown';
  }

  Future<void> checkUpdate({String from = ""}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final response = await http.get(Uri.parse('${Data.srvIp}version/'));
    debugPrint(response.body);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final remoteVersion = semver.Version.parse(jsonData['latest_version']);
      final localVersion = semver.Version.parse(packageInfo.version);

      if (remoteVersion > localVersion) {
        final platform = _getPlatform();
        final downloadUrl = _getDownloadUrl(jsonData, platform);

        showUpdateDialog(
          forceUpdate: jsonData['force_update'],
          downloadUrl: downloadUrl,
          platform: platform,
        );
      } else {
        if (from == "setting") {
          Get.snackbar('提示', '当前版本为最新版本');
        }
      }
    }
  }

  String _getDownloadUrl(Map<String, dynamic> jsonData, String platform) {
    if (platform == 'ios') {
      return jsonData['ios_download_url'] ?? jsonData['download_url'];
    } else if (platform == 'android') {
      return jsonData['android_download_url'] ?? jsonData['download_url'];
    }
    return jsonData['download_url'];
  }

  void showUpdateDialog({
    required bool forceUpdate,
    required String downloadUrl,
    required String platform,
  }) {
    showDialog(
      barrierDismissible: !forceUpdate,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('发现新版本'),
        content: Text('平台: ${platform == 'ios' ? 'iOS' : 'Android'}'),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('稍后'),
            ),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(downloadUrl)),
            child: Text('立即更新'),
          )
        ],
      ),
    );
  }
}
