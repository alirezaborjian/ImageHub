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
        title: 'Image Manager',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _themeMode,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => FutureBuilder(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final prefs = snapshot.data as SharedPreferences?;
                  final isLoggedIn = prefs?.getBool('isLoggedIn') ?? false;
                  if (isLoggedIn) {
                    final userName = prefs?.getString('userName') ?? 'User';
                    final avatarUrl = prefs?.getString('avatarUrl') ?? '';
                    return MainWrapper(
                      userName: userName,
                      initialAvatarUrl: avatarUrl,
                    );
                  }
                  return const LoginAndSignUp();
                },
              ),
            );
          }
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => const LoginAndSignUp(),
            );
          }
          if (settings.name == '/home') {
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