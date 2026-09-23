import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'auth_gate.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/borrow_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await NotificationService.instance.init();
  runApp(const IKeepingBooksApp());
}

class IKeepingBooksApp extends StatefulWidget {
  const IKeepingBooksApp({super.key});

  @override
  State<IKeepingBooksApp> createState() => _IKeepingBooksAppState();
}

class _IKeepingBooksAppState extends State<IKeepingBooksApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => BookProvider()..load()),
        ChangeNotifierProvider(create: (_) => BorrowProvider()..load()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'I-Keeping Books',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.themeMode,
            home: _showSplash
                ? SplashScreen(
                    onFinished: () {
                      if (mounted) setState(() => _showSplash = false);
                    },
                  )
                : const AuthGate(),
          );
        },
      ),
    );
  }
}
