import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'AlbumScreen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<ImageMock> _allImages = [];
  
  final List<AlbumMock> _myAlbums = [];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(images: _allImages),
      AlbumScreen(
        albums: _myAlbums,
        onCreateAlbum: (title) {
          setState(() {
            _myAlbums.add(AlbumMock(title: title, images: []));
          });
        },
        onRemoveImageFromAlbum: (album, img) {
          setState(() {
            album.images.remove(img);
          });
        },
      ),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
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
    );
  }
}