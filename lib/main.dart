import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'services/push_notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.initialize();

  String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  debugPrint('APNs device token: $apnsToken');


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
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
      title: 'TasksSphere',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
      locale: authProvider.user?.language != null ? Locale(authProvider.user!.language!) : null,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563eb),
          brightness: Brightness.dark,
          primary: const Color(0xFF3b82f6),
          surface: const Color(0xFF1f2937), // Gray-800
          onSurface: const Color(0xFFf9fafb),
        ),
        scaffoldBackgroundColor: const Color(0xFF111827), // Gray-900
        textTheme: GoogleFonts.figtreeTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.figtree(
            textStyle: ThemeData.dark().textTheme.displayLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.figtree(
            textStyle: ThemeData.dark().textTheme.displayMedium,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.figtree(
            textStyle: ThemeData.dark().textTheme.displaySmall,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.figtree(
            textStyle: ThemeData.dark().textTheme.headlineMedium,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.figtree(
            textStyle: ThemeData.dark().textTheme.titleLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(color: Color(0xFFd1d5db)), // Gray-300
          bodyMedium: const TextStyle(color: Color(0xFF9ca3af)), // Gray-400
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF9ca3af)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3b82f6),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1f2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF374151)), // Gray-700
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF374151)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3b82f6), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: Color(0xFF6b7280)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF374151)),
          ),
          color: const Color(0xFF1f2937),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF111827),
          surfaceTintColor: Color(0xFF111827),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563eb), // Blue-600
          primary: const Color(0xFF2563eb),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFf9fafb), // Gray-50
        textTheme: GoogleFonts.figtreeTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.figtree(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: GoogleFonts.figtree(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: GoogleFonts.figtree(
            textStyle: Theme.of(context).textTheme.displaySmall,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.figtree(
            textStyle: Theme.of(context).textTheme.headlineMedium,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.figtree(
            textStyle: Theme.of(context).textTheme.titleLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFf9fafb),
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF6b7280)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563eb),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFe5e7eb)), // Gray-200
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFe5e7eb)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563eb), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFf3f4f6)), // Gray-100
          ),
          color: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Future.microtask(() {
        if (mounted) {
          Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
        }
      });
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const TasksScreen();
    } else {
      return const LoginScreen();
    }
  }
}
