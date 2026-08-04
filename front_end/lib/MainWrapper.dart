import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';
import 'UploadScreen.dart';
import 'CustomDrawer.dart';
import 'UserProvider.dart';
import 'SocketService.dart';

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
  late List<ImageModel> _allImages;
  late List<AlbumModel> _myAlbums;
  late String _userName;
  late String _avatarUrl;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _avatarUrl = widget.initialAvatarUrl;
    _allImages = [];
    _myAlbums = [];
  }

  void _addImage(ImageModel newImg) {
    setState(() {
      _allImages.add(newImg);
    });
  }

  void _deleteImage(ImageModel img) async {
    final response = await SocketService().sendRequest({
      'action': 'deleteImage',
      'username': _userName,
      'name': img.name,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        _allImages.remove(img);
        for (var album in _myAlbums) {
          album.images.remove(img);
        }
      });
    }
  }

  void _createAlbum(String title) {
    setState(() {
      _myAlbums.add(AlbumModel(title: title, images: []));
    });
  }

  void _deleteWholeAlbum(AlbumModel album) {
    setState(() {
      _myAlbums.remove(album);
    });
  }

  void _removeImageFromAlbum(AlbumModel album, ImageModel img) async {
    final response = await SocketService().sendRequest({
      'action': 'removeImageFromAlbum',
      'username': _userName,
      'title': album.title,
      'name': img.name,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        album.images.remove(img);
      });
    }
  }

  void _updateAlbumCover(AlbumModel album, String url) {
    setState(() {
      album.coverUrl = url;
    });
  }

  void _moveImageToAnotherAlbum(
    AlbumModel source,
    AlbumModel target,
    ImageModel img,
  ) async {
    final response = await SocketService().sendRequest({
      'action': 'moveImage',
      'username': _userName,
      'sourceAlbum': source.title,
      'targetAlbum': target.title,
      'imageName': img.name,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        source.images.remove(img);
        target.images.add(img);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      userName: _userName,
      avatarUrl: _avatarUrl,
      allImages: _allImages,
      allAlbums: _myAlbums,
      updateUserName: (name) => setState(() => _userName = name),
      updateAvatarUrl: (url) => setState(() => _avatarUrl = url),
      updateImages: (images) => setState(() => _allImages = images),
      updateAlbums: (albums) => setState(() => _myAlbums = albums),
      child: Scaffold(
        drawer: const CustomDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Gallery'),
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
                label: const Text(
                  'Add Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadScreen(
                        currentUserName: _userName,

                        onImageUploaded: _addImage,
                      ),
                    ),
                  );
                },
              )
            : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              images: _allImages,
              userName: _userName,
              onImageDeleted: _deleteImage,
            ),
            AlbumScreen(
              albums: _myAlbums,
              allImages: _allImages,
              userName: _userName,
              onCreateAlbum: _createAlbum,
              onRemoveImageFromAlbum: _removeImageFromAlbum,
              onUpdateCover: _updateAlbumCover,
              onDeleteAlbum: _deleteWholeAlbum,
              onMoveImageToAnotherAlbum: _moveImageToAnotherAlbum,
            ),
          ],
        ),
      ),
    );
  }
}
