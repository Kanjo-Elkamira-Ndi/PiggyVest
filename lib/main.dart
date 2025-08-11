import 'package:flutter/material.dart';
import 'package:piggyvest/pages/accountValidation.dart';
import 'package:piggyvest/pages/login.dart';
import 'package:piggyvest/pages/signup.dart';

import 'models/validationData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiggyVest',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => SignupScreen());
          case '/validation':
            final data = settings.arguments as ValidationData;
            return MaterialPageRoute(
              builder: (_) => AccountValidationScreen(validationData: data),
            );
        }
        return null;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
