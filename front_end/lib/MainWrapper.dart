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

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
    _saveUserData();
  }

  void _updateAvatarUrl(String newAvatar) {
    setState(() {
      _avatarUrl = newAvatar;
    });
    _saveUserData();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('avatarUrl', _avatarUrl);
  }

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _avatarUrl = widget.initialAvatarUrl;

    _allImages = [
      ImageMock(
        name: 'Nature sunset',
        caption: 'A beautiful sunset over the mountains.',
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500',
        likes: 12,
        tags: ['Sunset', 'Nature', 'Mountains'],
        comments: [
          CommentMock(userName: 'Alice', text: 'Stunning view!'),
          CommentMock(userName: 'Bob', text: 'Wish I was there.'),
        ],
      ),
      ImageMock(
        name: 'Ocean breeze',
        caption: 'Crystal clear water under a sunny sky.',
        imageUrl: 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=500',
        likes: 24,
        tags: ['Ocean', 'Beach', 'Summer'],
        comments: [],
      ),
      ImageMock(
        name: 'Forest trail',
        caption: 'Walking through the misty pine forest.',
        imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=500',
        likes: 8,
        tags: ['Forest', 'Mist', 'Trees'],
        comments: [],
      ),
    ];

    _myAlbums = [
      AlbumMock(
        title: 'Favorites',
        images: [_allImages[0], _allImages[1]],
        coverUrl: _allImages[0].imageUrl,
      ),
      AlbumMock(
        title: 'Trip 2024',
        images: [_allImages[2]],
        coverUrl: _allImages[2].imageUrl,
      ),
    ];
  }

  void _addImage(ImageMock newImage) {
    setState(() {
      _allImages.add(newImage);
    });
  }

  void _deleteImage(ImageMock item) {
    setState(() {
      _allImages.remove(item);
      for (var album in _myAlbums) {
        album.images.remove(item);
        if (album.coverUrl == item.imageUrl) {
          album.coverUrl = album.images.isNotEmpty ? album.images.first.imageUrl : '';
        }
      }
    });
  }

  void _createAlbum(String title) {
    setState(() {
      _myAlbums.add(AlbumMock(title: title, images: [], coverUrl: ''));
    });
  }

  void _deleteWholeAlbum(AlbumMock album) {
    setState(() {
      _myAlbums.remove(album);
    });
  }

  void _removeImageFromAlbum(AlbumMock album, ImageMock image) {
    setState(() {
      album.images.remove(image);
      if (album.coverUrl == image.imageUrl) {
        album.coverUrl = album.images.isNotEmpty ? album.images.first.imageUrl : '';
      }
    });
  }

  void _moveImageToAnotherAlbum(AlbumMock sourceAlbum, AlbumMock targetAlbum, ImageMock image) {
    setState(() {
      sourceAlbum.images.remove(image);
      if (sourceAlbum.coverUrl == image.imageUrl) {
        sourceAlbum.coverUrl = sourceAlbum.images.isNotEmpty ? sourceAlbum.images.first.imageUrl : '';
      }
      if (!targetAlbum.images.contains(image)) {
        targetAlbum.images.add(image);
        if (targetAlbum.coverUrl.isEmpty) {
          targetAlbum.coverUrl = image.imageUrl;
        }
      }
    });
  }

  void _updateAlbumCover(AlbumMock album, String url) {
    setState(() {
      album.coverUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      userName: _userName,
      avatarUrl: _avatarUrl,
      allImages: _allImages,
      allAlbums: _myAlbums,
      updateUserName: _updateUserName,
      updateAvatarUrl: _updateAvatarUrl,
      updateImages: (images) => setState(() => _allImages = images),
      updateAlbums: (albums) => setState(() => _myAlbums = albums),
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: Text(_currentIndex == 0 ? 'Gallery' : 'My Albums'),
          backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
          foregroundColor: Colors.white,
        ),
        body: _buildCurrentScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: changeTab,
          selectedItemColor: const Color.fromRGBO(143, 148, 251, 1),
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
          onDeleteAlbum: _deleteWholeAlbum,
          onMoveImageToAnotherAlbum: _moveImageToAnotherAlbum,
        );
      default:
        return Container();
    }
  }
}