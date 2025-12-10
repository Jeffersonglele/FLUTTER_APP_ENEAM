import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eneam_projet/pages/dashboard.dart';
import 'package:eneam_projet/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(surfaceTintColor: Colors.white),
        ),
        home: const ConcentricAnimationOnboarding(),
      ),
    );
  }
}
