import 'package:flutter/material.dart';
import 'package:piggyvest/pages/accountValidation.dart';
import 'package:piggyvest/pages/login.dart';
import 'package:piggyvest/pages/signup.dart';
import 'models/validationData.dart';
import 'pages/onboardingScreen1.dart';
import 'pages/onboardingScreen2.dart';
import 'pages/onboardingScreen3.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiggyVest',
      initialRoute: '/', // default entry screen
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
          case '/onboarding2':
            return MaterialPageRoute(builder: (_) => OnboardingScreen2());
          case '/onboarding3':
            return MaterialPageRoute(builder: (_) => OnboardingScreen3());

          case '/dashboard':
            return MaterialPageRoute(builder: (_) => DashboardScreen());
          case '/createGoal':
            return MaterialPageRoute(builder: (_) => CreateGoalScreen());
          case '/savings':
            return MaterialPageRoute(builder: (_) => SavingsScreen());
          case '/ongoingGoals':
            return MaterialPageRoute(builder: (_) => PersonalGoalsScreen());
          case '/completedGoals':
            return MaterialPageRoute(builder: (_) => TerminatedGoalScreen());
          case '/reserves':
            return MaterialPageRoute(builder: (_) => ReservesScreen());
          case '/deposit':
            return MaterialPageRoute(builder: (_) => DepositScreen());
          case '/depositPage':
            return MaterialPageRoute(builder: (_) => TopUpScreen());
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
