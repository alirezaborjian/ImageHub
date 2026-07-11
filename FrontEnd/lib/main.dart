import 'package:flutter/material.dart';
import 'LoginAndSignUp.dart';
import 'MainWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

//      تنظیمات   مسیریابی

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      

      //  مسیرهای ثابت 
  
      routes: {
        '/': (context) => const LoginAndSignUp(),
        '/home': (context) => const MainWrapper(userName: 'User'),
        '/login': (context) => const LoginAndSignUp(),
        '/albums': (context) => const MainWrapper(userName: 'User'),
      },

      //  مسیریابی پویا 
      onGenerateRoute: (settings) {
        //   بررسی لاگین و هدایت به صفحه مناسب
  
        if (settings.name == '/' || settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => FutureBuilder(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                // در حال بارگذاری - نمایش دایره بارگذاری
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                // کاربر لاگین کرده - دریافت اطلاعات و رفتن به صفحه اصلی
                if (snapshot.data == true) {
                  return FutureBuilder(
                    future: _getUserData(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final data = userSnapshot.data;
                      return MainWrapper(
                        userName: data?['userName'] ?? 'User',
                        initialAvatarUrl: data?['avatarUrl'] ?? '',
                      );
                    },
                  );
                }
                // کاربر لاگین نکرده - رفتن به صفحه لاگین
                return const LoginAndSignUp();
              },
            ),
          );
        }

        // 📍 مسیر '/albums' - دریافت اطلاعات و رفتن به صفحه آلبوم‌ها

        if (settings.name == '/albums') {
          return MaterialPageRoute(
            builder: (context) => FutureBuilder(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = snapshot.data;
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
    );
  }

  //   خوبررسی وضعیت لاگین   

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  //  دریافت اطلاعات کاربر
  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? 'User',
      'avatarUrl': prefs.getString('avatarUrl') ?? '',
    };
  }
}