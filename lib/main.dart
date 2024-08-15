import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/provider/localdb.dart';
import 'firebase_options.dart';
import 'screen/auth/auth.dart';
import 'screen/mainapp/homelanding.dart';

Future<bool> checklogin() async {
  LocalDbProvider localdb = LocalDbProvider();
  return localdb.checklogin();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MyApp(
      login: await checklogin(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool login;
  const MyApp({super.key, required this.login});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sri Softwarez Pos',
      theme: ThemeData(
        // primaryColor: const Color(0xff59C1BD),
        primaryColor: const Color(0xff003049),
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xff003049),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xfff1f5f9),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: login ? const HomeLanding() : const Auth(),
    );
  }
}
