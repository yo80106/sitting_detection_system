import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/time_tracking_screen.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/ble_log_screen.dart';
import 'components/bottom_navigator.dart';
// import 'screens/background_screen.dart';
// import 'screens/bluetooth_screen_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    initialRoute: WelcomeScreen.id,
    routes: {
      WelcomeScreen.id: (context) => WelcomeScreen(),
      LoginScreen.id: (context) => LoginScreen(),
      RegistrationScreen.id: (context) => RegistrationScreen(),
      TimeTrackerScreen.id: (context) => TimeTrackerScreen(),
      BottomNavigator.id: (context) => BottomNavigator(),
      BleScreen.id: (context) => BleScreen(),
      BleLogScreen.id: (context) => BleLogScreen(),
    },
  );
}
