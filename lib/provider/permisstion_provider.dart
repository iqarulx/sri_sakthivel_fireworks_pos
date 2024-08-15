import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<bool?> storagePermission() async {
    bool? result;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          if (await Permission.photos.request().isGranted && await Permission.videos.request().isGranted) {
            result = true;
          } else {
            result = false;
          }
        } else {
          if (await Permission.storage.request().isGranted) {
            result = true;
          } else {
            result = false;
          }
        }
      } else if (Platform.isIOS) {
        // Map<Permission, PermissionStatus> statuses = await [
        //   Permission.photos,
        //   Permission.storage,
        // ].request();
        // log(statuses[Permission.photos].toString());

        if (await Permission.storage.request().isGranted) {
          await Permission.photos.request().then((value) {
            log("Photos Permission Completed");

            if (value.isGranted) {
              log("Photos Permission Status Success");
              result = true;
            } else {
              openAppSettings();
              log(value.toString());
            }
          }).catchError((onError) {
            throw onError.toString();
          });
        } else if (await Permission.storage.isPermanentlyDenied) {
          openAppSettings();
        } else if (await Permission.photos.isDenied || await Permission.storage.isDenied) {
          if (await Permission.storage.isDenied) {
            await Permission.storage.request().then((value) {
              result = true;
            });
          } else {
            await Permission.photos.request().then((value) {
              if (value.isGranted) {
                result = true;
              }
            });
          }
        } else {
          result = false;
        }
      }
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
    return result;
  }
}
