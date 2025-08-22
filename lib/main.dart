import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';

// Screens

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/profile_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/notification_detail_screen.dart';

import 'firebase_options.dart'; // generado por flutterfire configure

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // 🔑 Aseguramos que Flutter esté inicializado antes de async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 Cargar variables de entorno
  await dotenv.load(fileName: "assets/.env");

  // 🔑 Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔑 Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 🔑 Lanzamos la app
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(prefs: prefs),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: 'Artacho App Dev',
            theme: ThemeData(primarySwatch: Colors.blue),
            initialRoute: '/',
            onGenerateRoute: (settings) {
              // 🔒 Bloqueamos rutas privadas si no está autenticado
              if (!authProvider.isAuthenticated &&
                  ['/dashboard', '/profile', '/main'].contains(settings.name)) {
                return MaterialPageRoute(
                    builder: (context) => const HomeScreen());
              }

              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (context) => authProvider.isAuthenticated
                        ? const DashboardScreen()
                        : const HomeScreen(),
                  );
                case '/main':
                  return MaterialPageRoute(
                      builder: (context) => const MainScaffold());
                case '/dashboard':
                  return MaterialPageRoute(
                      builder: (context) => const DashboardScreen());
                case '/login':
                  return MaterialPageRoute(
                      builder: (context) => const LoginScreen());
                case '/register':
                  return MaterialPageRoute(
                      builder: (context) => const RegisterScreen());
                case '/forgot-password':
                  return MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen());
                case '/profile':
                  return MaterialPageRoute(
                      builder: (context) => const ProfileScreen());
                case '/feedback':
                  return MaterialPageRoute(
                      builder: (context) => const FeedbackScreen());
                case '/notification-detail':
                  final data = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (context) => NotificationDetailScreen(data: data),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => authProvider.isAuthenticated
                        ? const DashboardScreen()
                        : const HomeScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
