import 'package:device_info_plus/device_info_plus.dart';

import '../firebase/datamodel/datamodel.dart';
import 'dart:io';

class DeviceInformation {
  Future<DeviceModel?> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    DeviceModel? deviceModel = DeviceModel();
    String? deviceId;
    String? deviceName;
    String? deviceType;
    String? modelName;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id.toString();
      deviceName = androidInfo.brand.toString();
      modelName = androidInfo.model.toString();
      deviceType = "Android";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceName = iosDeviceInfo.name.toString();
      modelName = iosDeviceInfo.model.toString();
      deviceId = iosDeviceInfo.identifierForVendor.toString();
      deviceType = "Ios";
    }

    deviceModel.deviceId = deviceId;
    deviceModel.deviceName = deviceName;
    deviceModel.deviceType = deviceType;
    deviceModel.modelName = modelName;

    return deviceModel;
  }
}
