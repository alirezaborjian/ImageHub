import 'package:flutter/material.dart';
import 'LoginAndSignUp.dart';
import 'MainWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      toggleTheme: toggleTheme,
      isDarkMode: _themeMode == ThemeMode.dark,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Image Gallery',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.grey[900],
        ),
        themeMode: _themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginAndSignUp(),
          '/login': (context) => const LoginAndSignUp(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home' || settings.name == '/albums') {
            return MaterialPageRoute(
              builder: (context) => FutureBuilder(
                future: _getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final data = snapshot.data as Map<String, dynamic>?;
                  return MainWrapper(
                    userName: data?['userName'] ?? 'User',
                    initialAvatarUrl: data?['avatarUrl'] ?? '',
                  );
                },
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? 'User',
      'avatarUrl': prefs.getString('avatarUrl') ?? '',
    };
  }
}

class ThemeProvider extends InheritedWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const ThemeProvider({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}