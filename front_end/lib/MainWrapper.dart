import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';
import 'CustomDrawer.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  final String initialAvatarUrl;

  const MainWrapper({
    super.key,
    required this.userName,
    this.initialAvatarUrl = '',
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      currentUserName: widget.userName,
    );
  }
}