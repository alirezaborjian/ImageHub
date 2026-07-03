import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';

class UserProvider extends InheritedWidget {
  final String userName;
  final String avatarUrl; // ✅ اضافه شد
  final List<ImageMock> allImages;
  final List<AlbumMock> allAlbums;
  final Function(String) updateUserName;
  final Function(String) updateAvatarUrl; // ✅ اضافه شد
  final Function(List<ImageMock>) updateImages;
  final Function(List<AlbumMock>) updateAlbums;

  const UserProvider({
    super.key,
    required this.userName,
    required this.avatarUrl, // ✅ اضافه شد
    required this.allImages,
    required this.allAlbums,
    required this.updateUserName,
    required this.updateAvatarUrl, // ✅ اضافه شد
    required this.updateImages,
    required this.updateAlbums,
    required super.child,
  });

  static UserProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserProvider>();
  }

  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return userName != oldWidget.userName ||
        avatarUrl != oldWidget.avatarUrl || // ✅ اضافه شد
        allImages != oldWidget.allImages ||
        allAlbums != oldWidget.allAlbums;
  }
}