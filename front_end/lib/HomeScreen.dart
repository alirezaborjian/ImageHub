import 'dart:convert';
import 'package:flutter/material.dart';
import 'UploadScreen.dart';
import 'AlbumScreen.dart';
import 'SocketService.dart';
import 'CustomDrawer.dart';
import 'ImageDetailsScreen.dart';

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
  String _sortBy = 'none'; // 'none', 'likes'

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

  void _deleteImage(ImageModel img) async {
    final response = await SocketService().sendRequest({
      'action': 'deleteImage',
      'name': img.name,
      'username': widget.currentUserName,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        _allImages.removeWhere((item) => item.name == img.name);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Could not delete image')),
        );
      }
    }
  }

  void _sortImages(String criteria) {
    setState(() {
      _sortBy = criteria;
      if (criteria == 'likes') {
        _allImages.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (criteria == 'name') {
        _allImages.sort((a, b) => a.name.compareTo(b.name));
      }
    });
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
      );
    }

    try {
      String base64Str = cleanData.contains(',') ? cleanData.split(',').last : cleanData;
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } catch (e) {
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
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDetailsScreen(
                    imageItem: img,
                    currentUserName: widget.currentUserName,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildImageWidget(img.imageUrl)),
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
                // دکمه حذف سطل زباله روی هر کارت
                Positioned(
                  top: 4,
                  right: 4,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                      onPressed: () => _deleteImage(img),
                    ),
                  ),
                ),
              ],
            ),
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
        title: Text(_selectedIndex == 0 ? 'Explore' : 'Albums'),
        actions: _selectedIndex == 0
            ? [
                // منوی مرتب‌سازی
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: _sortImages,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'likes',
                      child: Text('Sort by Likes'),
                    ),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Sort by Name'),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_selectedIndex == 0
              ? _buildGalleryView()
              : AlbumScreen(
                  albums: _userAlbums,
                  userName: widget.currentUserName,
                  allImages: _allImages,
                  onCreateAlbum: (title) => setState(() => _userAlbums.add(AlbumModel(title: title, images: []))),
                  onDeleteAlbum: (album) => setState(() => _userAlbums.remove(album)),
                  onRemoveImageFromAlbum: (album, img) {},
                  onMoveImageToAnotherAlbum: (s, t, img) {},
                  onUpdateCover: (a, c) {},
                )),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadScreen(
                      currentUserName: widget.currentUserName,
                      onImageUploaded: (newImg) => setState(() => _allImages.add(newImg)),
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
        onTap: (index) => setState(() => _selectedIndex = index),
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