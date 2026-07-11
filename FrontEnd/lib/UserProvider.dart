import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';

class UserProvider extends InheritedWidget {
  //   فیلدهای ذخیره‌سازی داده‌ها
  final String userName;
  final String avatarUrl;
  final List<ImageMock> allImages;
  final List<AlbumMock> allAlbums;
  final Function(String) updateUserName;
  final Function(String) updateAvatarUrl;
  final Function(List<ImageMock>) updateImages;
  final Function(List<AlbumMock>) updateAlbums;

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
  //  متد دسترسی به Provider - استفاده: UserProvider.of(context)
  static UserProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserProvider>();
  }
  // تشخیص تغییرات - مشخص میکند ویجت‌های وابسته ری‌بیلد شوند یا نه
  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return userName != oldWidget.userName ||
        avatarUrl != oldWidget.avatarUrl ||
        allImages != oldWidget.allImages ||
        allAlbums != oldWidget.allAlbums;
  }
}