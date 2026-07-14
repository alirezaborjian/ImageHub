import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserProvider.dart';
import 'main.dart';

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
    final themeProvider = ThemeProvider.of(context);
    final isAdmin = userName.toLowerCase() == 'admin';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(isAdmin ? 'System Administrator' : 'Standard User'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(userName[0].toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.blue)),
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
            leading: const Icon(Icons.photo_album),
            title: const Text('My Albums'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToAlbums != null) onNavigateToAlbums!();
            },
          ),
          SwitchListTile(
            secondary: Icon(themeProvider?.isDarkMode == true ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Dark Mode'),
            value: themeProvider?.isDarkMode ?? false,
            onChanged: (value) {
              themeProvider?.toggleTheme(value);
            },
          ),
          if (isAdmin) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                'Admin Control Panel',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.gavel, color: Colors.red),
              title: const Text('Manage & Ban Users'),
              onTap: () {
                Navigator.pop(context);
                _showBanUserDialog(context);
              },
            ),
          ],
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (onLogout != null) onLogout!();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  void _showBanUserDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User Account'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Enter username to ban'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final username = textController.text.trim();
              if (username.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('banned_$username', true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User "$username" has been permanently banned.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban'),
          )
        ],
      ),
    );
  }
}