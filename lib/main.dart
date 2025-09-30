import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'providers/auth_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/feedback_screen.dart';
import 'providers/event_provider.dart';
import 'screens/events_list_screen.dart';
import 'screens/events_calendar_screen.dart';
import 'screens/event_detail_screen.dart';

// Clave global para navegación desde notificaciones
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await dotenv.load(fileName: "assets/.env");

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (!authProvider.isAuthenticated &&
            ['/dashboard', '/profile', '/main'].contains(settings.name)) {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }

        switch (settings.name) {
          case '/main':
            return MaterialPageRoute(
                builder: (context) => const MainScaffold());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(
                builder: (context) => const RegisterScreen());
          case '/forgot-password':
            return MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen());
          case '/dashboard':
            return MaterialPageRoute(
                builder: (context) => const MainScaffold());
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
          case '/events':
            return MaterialPageRoute(
                builder: (context) => const EventsListScreen());
          case '/events-calendar':
            return MaterialPageRoute(
                builder: (context) => const EventsCalendarScreen());
          case '/event-detail':
            final event = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => authProvider.isAuthenticated
                  ? const MainScaffold()
                  : const HomeScreen(),
            );
        }
      },
      initialRoute: '/',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const frase = 'A poc a poc i bona lletra.';

    // Separar la versión del build number
    String versionDisplay = _version;
    if (_version.contains('+')) {
      final parts = _version.split('+');
      versionDisplay = '${parts[0]} (${parts[1]})';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Artacho App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👋 Hola 👋', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Entrar'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Registrarse'),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: const Text('Recuperar contraseña'),
            ),
            const SizedBox(height: 40),
            // Widget extraído - ahora puede ser const
            _FooterSection(frase: frase, versionDisplay: versionDisplay),
          ],
        ),
      ),
    );
  }
}

// Widget separado y constante
class _FooterSection extends StatelessWidget {
  final String frase;
  final String versionDisplay;

  const _FooterSection({
    required this.frase,
    required this.versionDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '“$frase”',
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          'Versió: $versionDisplay',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotificationDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Notificación')),
      body: Center(
        child: Text(data.toString(), style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
