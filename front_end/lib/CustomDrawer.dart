import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserProvider.dart';
import 'SocketService.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToAlbums;

  const CustomDrawer({
    super.key,
    this.onLogout,
    this.onNavigateToHome,
    this.onNavigateToAlbums,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProvider.of(context)!;
    final userName = userProvider.userName;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: const Text('Standard User'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(userName.isEmpty ? 'U' : userName[0].toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.blue)),
            ),
            decoration: const BoxDecoration(color: Color.fromRGBO(143, 148, 251, 1)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToHome != null) onNavigateToHome!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.collections),
            title: const Text('Albums'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToAlbums != null) onNavigateToAlbums!();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await SocketService().sendRequest({'action': 'logout'});
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (onLogout != null) onLogout!();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}