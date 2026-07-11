import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';
import 'UploadScreen.dart';
import 'CustomDrawer.dart';
import 'UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _currentIndex = 0;
  late List<ImageMock> _allImages;
  late List<AlbumMock> _myAlbums;
  late String _userName;
  late String _avatarUrl;

  //  تغییر تب فعال (گالری یا آلبوم‌ها)
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  //  به‌روزرسانی نام کاربری  
  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
    _saveUserData();
  }

  // 🖼️ به‌روزرسانی آواتار    

  void _updateAvatarUrl(String newAvatar) {
    setState(() {
      _avatarUrl = newAvatar;
    });
    _saveUserData();
  }

  //  به‌روزرسانی لیست تصاویر

  void _updateImages(List<ImageMock> newImages) {
    setState(() {
      _allImages = newImages;
    });
  }

  //  به‌روزرسانی لیست آلبوم‌ها
  void _updateAlbums(List<AlbumMock> newAlbums) {
    setState(() {
      _myAlbums = newAlbums;
    });
  }

  //  ذخیره اطلاعات کاربر  

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    if (_avatarUrl.isNotEmpty) {
      await prefs.setString('avatarUrl', _avatarUrl);
    } else {
      await prefs.remove('avatarUrl');
    }
  }

  //  افزودن تصویر جدید به لیست گالری

  void _addImage(ImageMock image) {
    setState(() {
      _allImages.add(image);
    });
  }

  //  حذف تصویر از گالری و تمام آلبوم‌ها

  void _deleteImage(ImageMock image) {
    setState(() {
      _allImages.remove(image);
      for (var album in _myAlbums) {
        album.images.remove(image);
      }
    });
  }

  //  ساخت آلبوم جدید با عنوان داده شده
  void _createAlbum(String title) {
    setState(() {
      _myAlbums.add(AlbumMock(title: title, images: []));
    });
  }

  //  حذف تصویر از یک آلبوم خاص

  void _removeImageFromAlbum(AlbumMock album, ImageMock image) {
    setState(() {
      album.images.remove(image);
    });
  }

  //  تغییر کاور آلبوم

  void _updateAlbumCover(AlbumMock album, String coverUrl) {
    setState(() {
      album.coverUrl = coverUrl;
    });
  }


  //  مقداردهی اولیه 
  @override
  void initState() {
    super.initState();
    _allImages = [];
    _myAlbums = [];
    _userName = widget.userName;
    _avatarUrl = widget.initialAvatarUrl;
  }

  //   UI
  @override
  Widget build(BuildContext context) {
    return UserProvider(
      userName: _userName,
      avatarUrl: _avatarUrl,
      allImages: _allImages,
      allAlbums: _myAlbums,
      updateUserName: _updateUserName,
      updateAvatarUrl: _updateAvatarUrl,
      updateImages: _updateImages,
      updateAlbums: _updateAlbums,
      child: Scaffold(

        appBar: AppBar(
          title: const Text('My Gallery'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: Colors.black87,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        // بدنه - نمایش صفحه بر اساس تب انتخاب شده
        body: _buildCurrentScreen(),
        // منوی کشویی
        drawer: CustomDrawer(
          onNavigateToHome: () => changeTab(0),
          onNavigateToAlbums: () => changeTab(1),
        ),
        // نوار پایین با دو تب
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color.fromRGBO(143, 148, 251, 1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark),
              label: 'Albums',
            ),
          ],
        ),
        // دکمه شناور - فقط در تب گالری نمایش داده می‌شود
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                label: const Text('Add Photo', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadScreen(
                        onImageUploaded: _addImage,
                      ),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
  //  ساخت صفحه بر اساس تب انتخاب شده (گالری یا آلبوم‌ها)

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          images: _allImages,
          userName: _userName,
          onImageDeleted: _deleteImage,
        );
      case 1:
        return AlbumScreen(
          albums: _myAlbums,
          allImages: _allImages,
          onCreateAlbum: _createAlbum,
          onRemoveImageFromAlbum: _removeImageFromAlbum,
          onUpdateCover: _updateAlbumCover,
        );
      default:
        return Container();
    }
  }
}