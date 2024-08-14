import 'package:flutter/material.dart';

import 'app/speedtest_connect.dart';

void main() {
  return runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedtest Connect',
      theme: ThemeData.dark(),
      home: const SpeedtestConnect(),
      debugShowCheckedModeBanner: false,
    );
  }
}
