import 'dart:convert';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'UploadScreen.dart';
import 'SocketService.dart';
import 'CustomDrawer.dart';

class AlbumModel {
  final String title;
  String coverUrl;
  final List<ImageModel> images;

  AlbumModel({
    required this.title,
    required this.images,
    this.coverUrl = '',
  });
}

class AlbumScreen extends StatefulWidget {
  final List<AlbumModel> albums;
  final String userName;
  final Function(String) onCreateAlbum;
  final Function(AlbumModel, ImageModel) onRemoveImageFromAlbum;
  final Function(AlbumModel, String) onUpdateCover;
  final Function(AlbumModel) onDeleteAlbum;
  final Function(String, String, ImageModel) onMoveImageToAnotherAlbum;
  final List<ImageModel> allImages;

  const AlbumScreen({
    super.key,
    required this.albums,
    required this.userName,
    required this.onCreateAlbum,
    required this.onRemoveImageFromAlbum,
    required this.onUpdateCover,
    required this.onDeleteAlbum,
    required this.onMoveImageToAnotherAlbum,
    required this.allImages,
  });

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final TextEditingController _albumTitleController = TextEditingController();

  @override
  void dispose() {
    _albumTitleController.dispose();
    super.dispose();
  }

  void _handleCreateAlbum() async {
    final title = _albumTitleController.text.trim();
    if (title.isEmpty) return;

    final response = await SocketService().sendRequest({
      'action': 'createAlbum',
      'username': widget.userName,
      'title': title,
    });

    if (response['statusCode'] == 200) {
      widget.onCreateAlbum(title);
      _albumTitleController.clear();
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Could not create album'),
          ),
        );
      }
    }
  }

  void _handleDeleteAlbum(AlbumModel album) async {
    final response = await SocketService().sendRequest({
      'action': 'deleteAlbum',
      'username': widget.userName,
      'title': album.title,
    });

    if (response['statusCode'] == 200) {
      widget.onDeleteAlbum(album);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Could not delete album'),
          ),
        );
      }
    }
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
        title: const Text('My Albums'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create Album'),
                  content: TextField(
                    controller: _albumTitleController,
                    decoration: const InputDecoration(hintText: 'Album Title'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _handleCreateAlbum,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: widget.albums.isEmpty
          ? const Center(child: Text('No albums yet.'))
          : ListView.builder(
              itemCount: widget.albums.length,
              itemBuilder: (context, index) {
                final album = widget.albums[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(album.title),
                  subtitle: Text('${album.images.length} images'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _handleDeleteAlbum(album),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailsScreen(
                          album: album,
                          allAlbums: widget.albums,
                          allImages: widget.allImages,
                          userName: widget.userName,
                          onRemoveImage: (img) =>
                              widget.onRemoveImageFromAlbum(album, img),
                          onMoveImage: (targetTitle, img) =>
                              widget.onMoveImageToAnotherAlbum(
                                  album.title, targetTitle, img),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class AlbumDetailsScreen extends StatefulWidget {
  final AlbumModel album;
  final List<AlbumModel> allAlbums;
  final List<ImageModel> allImages;
  final String userName;
  final Function(ImageModel) onRemoveImage;
  final Function(String, ImageModel) onMoveImage;

  const AlbumDetailsScreen({
    super.key,
    required this.album,
    required this.allAlbums,
    required this.allImages,
    required this.userName,
    required this.onRemoveImage,
    required this.onMoveImage,
  });

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  void _showImageOptions(ImageModel img) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.drive_file_move),
            title: const Text('Move to another album'),
            onTap: () {
              Navigator.pop(context);
              _showMoveDialog(img);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Remove from album',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onRemoveImage(img);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(ImageModel img) {
    final otherAlbums = widget.allAlbums
        .where((a) => a.title != widget.album.title)
        .toList();
    if (otherAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other albums available.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Select Target Album'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: otherAlbums.length,
            itemBuilder: (context, index) {
              final target = otherAlbums[index];
              return ListTile(
                title: Text(target.title),
                onTap: () async {
                  Navigator.pop(dialogCtx);
                  
                  final response = await SocketService().moveImage(
                    username: widget.userName,
                    sourceAlbum: widget.album.title,
                    targetAlbum: target.title,
                    imageName: img.name,
                  );

                  if (mounted && response['statusCode'] == 200) {
                    widget.onMoveImage(target.title, img);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image moved successfully.')),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? 'Could not move image')),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String data) {
    if (data.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
        ),
      );
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
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
            ),
          );
        },
      );
    }

    try {
      final base64Str = cleanData.contains(',') ? cleanData.split(',').last : cleanData;
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
            ),
          );
        },
      );
    } catch (_) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadScreen(
                    currentUserName: widget.userName,
                    onImageUploaded: (newImg) {
                      setState(() {
                        widget.album.images.add(newImg);
                        widget.allImages.add(newImg);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: widget.album.images.isEmpty
          ? const Center(child: Text('Album is empty'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: widget.album.images.length,
              itemBuilder: (context, index) {
                final img = widget.album.images[index];
                return GestureDetector(
                  onLongPress: () => _showImageOptions(img),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: _buildImageWidget(img.imageUrl)),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    img.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _showImageOptions(img),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}