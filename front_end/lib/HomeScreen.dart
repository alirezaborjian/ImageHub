import 'dart:convert';
import 'package:flutter/material.dart';
import 'UploadScreen.dart';
import 'AlbumScreen.dart';
import 'SocketService.dart';
import 'CustomDrawer.dart';

class ImageModel {
  final String name;
  final String caption;
  final String imageUrl;
  int likes;
  List<String> tags;
  List<CommentModel> comments;

  ImageModel({
    required this.name,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.tags,
    required this.comments,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    var tagsList = json['tags'] as List? ?? [];
    var commentsList = json['comments'] as List? ?? [];

    return ImageModel(
      name: json['name'] ?? '',
      caption: json['caption'] ?? '',
      imageUrl: json['imageUrl'] ?? json['base64Data'] ?? json['data'] ?? '',
      likes: json['likes'] ?? 0,
      tags: tagsList.map((e) => e.toString()).toList(),
      comments: commentsList.map((e) => CommentModel.fromJson(e)).toList(),
    );
  }
}

class CommentModel {
  final String username;
  final String text;

  CommentModel({required this.username, required this.text});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      username: json['username'] ?? json['userName'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String currentUserName;

  const HomeScreen({super.key, required this.currentUserName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<ImageModel> _allImages = [];
  List<AlbumModel> _userAlbums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    final socketService = SocketService();

    final imagesResponse = await socketService.sendRequest({'action': 'getAllImages'});
    final albumsResponse = await socketService.sendRequest({
      'action': 'getUserAlbums',
      'username': widget.currentUserName,
    });

    List<ImageModel> fetchedImages = [];
    if (imagesResponse['statusCode'] == 200 && imagesResponse['payload'] != null) {
      final List list = imagesResponse['payload'];
      fetchedImages = list.map((item) => ImageModel.fromJson(item)).toList();
    }

    List<AlbumModel> fetchedAlbums = [];
    if (albumsResponse['statusCode'] == 200 && albumsResponse['payload'] != null) {
      final List list = albumsResponse['payload'];
      fetchedAlbums = list.map((item) {
        final String title = item['title'] ?? '';
        final List imgsJson = item['images'] ?? [];
        final List<ImageModel> albumImgs =
            imgsJson.map((x) => ImageModel.fromJson(x)).toList();
        return AlbumModel(title: title, images: albumImgs);
      }).toList();
    }

    if (mounted) {
      setState(() {
        _allImages = fetchedImages;
        _userAlbums = fetchedAlbums;
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewImage(ImageModel newImg) {
    setState(() {
      _allImages.add(newImg);
    });
  }

  void _createAlbum(String title) {
    setState(() {
      _userAlbums.add(AlbumModel(title: title, images: []));
    });
  }

  void _deleteAlbum(AlbumModel album) {
    setState(() {
      _userAlbums.remove(album);
    });
  }

  void _removeImageFromAlbum(AlbumModel album, ImageModel img) async {
    final response = await SocketService().sendRequest({
      'action': 'removeImageFromAlbum',
      'username': widget.currentUserName,
      'title': album.title,
      'imageName': img.name,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        album.images.removeWhere((item) => item.name == img.name);
      });
    }
  }

  void _moveImageToAnotherAlbum(
      AlbumModel sourceAlbum, AlbumModel targetAlbum, ImageModel img) async {
    final response = await SocketService().sendRequest({
      'action': 'moveImage',
      'username': widget.currentUserName,
      'sourceAlbum': sourceAlbum.title,
      'targetAlbum': targetAlbum.title,
      'imageName': img.name,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        sourceAlbum.images.removeWhere((item) => item.name == img.name);
        targetAlbum.images.add(img);
      });
    }
  }

  Widget _buildImageWidget(String data) {
    if (data.isEmpty) {
      return _buildPlaceholder();
    }

    String cleanData = data.replaceAll(RegExp(r'\s+'), '');

    if (cleanData.startsWith('http://') || cleanData.startsWith('https://')) {
      String formattedUrl = cleanData
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');

      return Image.network(
        formattedUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    try {
      String base64Str = cleanData;
      if (cleanData.contains(',')) {
        base64Str = cleanData.split(',').last;
      }

      int missingPadding = base64Str.length % 4;
      if (missingPadding > 0) {
        base64Str += '=' * (4 - missingPadding);
      }

      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } catch (e) {
      debugPrint("Base64 Decode Error: $e");
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
      ),
    );
  }

  Widget _buildGalleryView() {
    if (_allImages.isEmpty) {
      return const Center(child: Text('No images available.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _allImages.length,
      itemBuilder: (context, index) {
        final img = _allImages[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildImageWidget(img.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        img.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${img.likes}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(_selectedIndex == 0 ? 'Explore' : 'Albums'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_selectedIndex == 0
              ? _buildGalleryView()
              : AlbumScreen(
                  albums: _userAlbums,
                  userName: widget.currentUserName,
                  allImages: _allImages,
                  onCreateAlbum: _createAlbum,
                  onDeleteAlbum: _deleteAlbum,
                  onRemoveImageFromAlbum: _removeImageFromAlbum,
                  onMoveImageToAnotherAlbum: _moveImageToAnotherAlbum,
                  onUpdateCover: (album, coverUrl) {},
                )),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadScreen(
                      currentUserName: widget.currentUserName,
                      onImageUploaded: _addNewImage,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Photo'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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