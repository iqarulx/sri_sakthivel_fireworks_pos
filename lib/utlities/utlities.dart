import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';

loading(context) {
  showDialog(
    context: context,
    builder: (context) {
      // return AlertDialog(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(10),
      //   ),
      //   contentPadding: const EdgeInsets.all(15),
      //   backgroundColor: Colors.white,
      //   content: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       CircularProgressIndicator(
      //         color: Theme.of(context).primaryColor,
      //       ),
      //       const SizedBox(
      //         width: 30,
      //       ),
      //       const Text(
      //         "Loading...",
      //         style: TextStyle(
      //           color: Colors.black,
      //           fontWeight: FontWeight.w500,
      //           fontSize: 15,
      //         ),
      //       ),
      //     ],
      //   ),
      // );
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    },
  );
}

snackBarCustom(context, bool isSuccess, String msg) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      content: Text(
        msg.toString(),
      ),
    ),
  );
}

downloadFileSnackBarCustom(context, {required bool isSuccess, required String msg, required String path}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      content: Text(
        msg.toString(),
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: "Open",
        onPressed: () async {
          log("path = $path");
          try {
            await OpenFile.open(path);
          } catch (e) {
            log(e.toString());
          }
        },
      ),
    ),
  );
}
