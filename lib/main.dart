import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'screens/login_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/macos_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, JobProvider>(
          create: (_) => JobProvider(null),
          update: (_, auth, previousJobs) {
            final provider = JobProvider(auth.sessionId, testMode: auth.testMode);
            provider.updatePrevious(previousJobs);
            return provider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          // Comment out or remove these lines to use real login
          // if (!auth.isAuth && kDebugMode) {
          //   auth.setTestSession("test_session_123", "test_user", "localhost");
          // }
          
          return MaterialApp(
            title: 'SWATCH - Slurm Job Monitor',
            theme: MacOSTheme.lightTheme,
            darkTheme: MacOSTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: auth.isAuth 
              ? const JobsScreen() 
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? const SplashScreen()
                        : const LoginScreen();
                  }),
            routes: {
              JobsScreen.routeName: (ctx) => const JobsScreen(),
              SettingsScreen.routeName: (ctx) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'SWATCH',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 