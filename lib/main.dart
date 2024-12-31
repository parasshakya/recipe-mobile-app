import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/firebase_options.dart';
import 'package:recipe_flutter_app/models/auth_model.dart';
import 'package:recipe_flutter_app/models/category_model.dart';
import 'package:recipe_flutter_app/models/chat_model.dart';
import 'package:recipe_flutter_app/models/cusine_model.dart';
import 'package:recipe_flutter_app/models/local_notification_model.dart';
import 'package:recipe_flutter_app/models/recipe_model.dart';
import 'package:recipe_flutter_app/models/socket_model.dart';
import 'package:recipe_flutter_app/models/user_model.dart';
import 'package:recipe_flutter_app/viewModels/category_view_model.dart';
import 'package:recipe_flutter_app/viewModels/chat_view_model.dart';
import 'package:recipe_flutter_app/viewModels/cuisine_view_model.dart';
import 'package:recipe_flutter_app/viewModels/local_notification_view_model.dart';
import 'package:recipe_flutter_app/viewModels/push_notification_view_model.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/viewModels/socket_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/home_view.dart';
import 'package:recipe_flutter_app/views/splash_view.dart';
import 'package:recipe_flutter_app/models/push_notification_model.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (context) => UserAuthViewModel(
              authModel: AuthModel(), userModel: UserModel())),
      ChangeNotifierProvider(
          create: (context) => RecipeViewModel(recipeModel: RecipeModel())),
      ChangeNotifierProvider(
          create: (context) => CuisineViewModel(cuisineModel: CuisineModel())),
      ChangeNotifierProvider(
          create: (context) => LocalNotificationViewModel(
              localNotificationModel: LocalNotificationModel())),
      ChangeNotifierProvider(
          create: (context) => PushNotificationViewModel(
              pushNotificationModel: PushNotificationModel())),
      ChangeNotifierProvider(
          create: (context) => SocketViewModel(socketModel: SocketModel())),
      ChangeNotifierProvider(
          create: (context) => ChatViewModel(chatModel: ChatModel())),
      ChangeNotifierProvider(
          create: (context) =>
              CategoryViewModel(categoryModel: CategoryModel())),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
      routes: {
        "/home": (context) => const HomeScreen(),
        "/splashScreen": (context) => const SplashScreen(),
      },
    );
  }
}
