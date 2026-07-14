import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';

class UserProvider extends InheritedWidget {
  final String userName;
  final String avatarUrl;
  final List<ImageModel> allImages;
  final List<AlbumModel> allAlbums;
  final Function(String) updateUserName;
  final Function(String) updateAvatarUrl;
  final Function(List<ImageModel>) updateImages;
  final Function(List<AlbumModel>) updateAlbums;

  const UserProvider({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.allImages,
    required this.allAlbums,
    required this.updateUserName,
    required this.updateAvatarUrl,
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
        avatarUrl != oldWidget.avatarUrl ||
        allImages != oldWidget.allImages ||
        allAlbums != oldWidget.allAlbums;
  }
}