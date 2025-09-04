import 'dart:ffi';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:piggyvest/pages/accountValidation.dart';
import 'package:piggyvest/pages/login.dart';
import 'package:piggyvest/pages/signup.dart';
import 'models/validationData.dart';
import 'pages/chart.dart';
import 'pages/onboardingScreen.dart';
import 'pages/createGoal.dart';
import 'pages/dashboard.dart';
import 'pages/savings.dart';
import 'pages/ongoingGoals.dart';
import 'pages/completedGoals.dart';
import 'pages/reserves.dart';
import 'pages/deposit.dart';
import 'pages/pinEntry.dart';
import 'pages/budgetting.dart';
import 'pages/topup.dart';
import 'pages/flip.dart';
import 'pages/depositPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage();
  final firstLogin = await storage.read(key: 'firstLogin');

  String starterPage;
  if (firstLogin == null || firstLogin == 'true') {
    await storage.write(key: 'firstLogin', value: 'false');
    starterPage = '/onboarding';
  } else {
    starterPage = '/';
  }

  runApp(MyApp(starterPage: starterPage));
}

class MyApp extends StatelessWidget {

  final String starterPage;

  const MyApp({Key? key, required this.starterPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiggyVest',
      initialRoute: starterPage, // default entry screen
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

          case '/onboarding1':
            return MaterialPageRoute(builder: (_) => OnboardingScreen());
          case '/chat':
            return MaterialPageRoute(builder: (_) => ChatScreen());

          case '/dashboard':
            return MaterialPageRoute(builder: (_) => DashboardScreen());
          case '/createGoal':
            return MaterialPageRoute(builder: (_) => CreateGoalScreen());
          case '/savings':
            final args = settings.arguments as Map<String, dynamic>?;
            final double totalAmount = double.tryParse(args?['amount']?.toString() ?? '0') ?? 0.0;
            return MaterialPageRoute(
              builder: (_) => SavingsScreen(amount: totalAmount),
            );
          case '/ongoingGoals':
            return MaterialPageRoute(builder: (_) => PersonalGoalsScreen());
          case '/completedGoals':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => TerminatedGoalScreen(),);
          case '/reserves':
            return MaterialPageRoute(builder: (_) => ReservesScreen());
          case '/deposit':
            return MaterialPageRoute(builder: (_) => DepositScreen());
          case '/depositPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => TopUpScreen(goalData: args),
            );
          case '/topup':
            return MaterialPageRoute(builder: (_) => TopUpBasicsScreen());
          case '/budgetting':
            return MaterialPageRoute(builder: (_) => BasicsScreen());
          case '/flip':
            return MaterialPageRoute(builder: (_) => FlipScreen());
          case '/pinEntry':
            return MaterialPageRoute(builder: (_) => PinEntryScreen());
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
