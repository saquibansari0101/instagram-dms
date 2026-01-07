import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dm_web_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set immersive mode-ish
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Set status bar color to transparent for better look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insta DM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DmWebView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
