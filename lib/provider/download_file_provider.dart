import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permisstion_provider.dart';

class DownloadFilesOnline {
  final String urlLink;
  final String fileName;
  final String fileext;
  DownloadFilesOnline({
    required this.urlLink,
    required this.fileName,
    required this.fileext,
  });

  Future<String?> startDownload() async {
    String? result;
    try {
      Dio dio = Dio();
      bool? permissionResult = await PermissionHandler().storagePermission();

      var status1 = await Permission.storage.status;
      var status2 = await Permission.photos.status;
      log("Ios Storage Permission Status $status1\nIos Photos Permission Status $status2");
      log(permissionResult.toString());
      if (permissionResult != null) {
        Directory? dir;
        if (Platform.isAndroid) {
          dir = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          dir = await getDownloadsDirectory();
        }
        log(dir.toString());
        if (dir != null) {
          String time = DateFormat('yyyy-MM-dd-hh-mm-a').format(DateTime.now()).toString();
          String filename = "${dir.path}/$fileName - $time.$fileext";
          var file = File(filename);

          await dio.download(
            urlLink,
            file.path,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                log("${(received / total * 100).toStringAsFixed(0)}%");
              }
            },
          );
          result = file.path;
        }
      }
    } catch (e) {
      rethrow;
    }
    return result;
  }
}

class DownloadFileOffline {
  final Uint8List fileData;
  final String fileName;
  final String fileext;
  DownloadFileOffline({
    required this.fileData,
    required this.fileName,
    required this.fileext,
  });
  Future<String?> startDownload() async {
    String? result;
    try {
      bool? permissionResult = await PermissionHandler().storagePermission();
      if (permissionResult != null) {
        Directory? dir;
        if (Platform.isAndroid) {
          dir = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          dir = await getApplicationDocumentsDirectory();
        }

        if (dir != null) {
          String time = DateFormat('yyyy-MM-dd-hh-mm-a').format(DateTime.now()).toString();
          String filename = "${dir.absolute.path}/$fileName - $time.$fileext";
          log(filename.toString());
          var file = await File(filename).writeAsBytes(fileData);
          if (await file.exists()) {
            result = file.path;
          } else {
            result = null;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return result;
  }
}
