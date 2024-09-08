import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/firebase_options.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/providers/user_provider.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/screens/splash_screen.dart';
import 'package:recipe_flutter_app/services/local_notification_service.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService().init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => RecipeProvider()),
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      navigatorKey: navigatorKey,
      routes: {
        "/home": (context) => const HomeScreen(),
        "/splashScreen": (context) => const SplashScreen(),
      },
    );
  }
}
