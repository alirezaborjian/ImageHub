import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'UploadScreen.dart';
import 'SocketService.dart';
import 'UserProvider.dart';

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
  final Function(String) onCreateAlbum;
  final Function(AlbumModel, ImageModel) onRemoveImageFromAlbum;
  final Function(AlbumModel, String) onUpdateCover;
  final Function(AlbumModel) onDeleteAlbum;
  final Function(AlbumModel, AlbumModel, ImageModel) onMoveImageToAnotherAlbum;
  final List<ImageModel> allImages;

  const AlbumScreen({
    super.key,
    required this.albums,
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

    final userName = UserProvider.of(context)?.userName ?? "User";
    final response = await SocketService().sendRequest({
      'action': 'createAlbum',
      'username': userName,
      'title': title,
    });

    if (response['status'] == 'success') {
      widget.onCreateAlbum(title);
      _albumTitleController.clear();
      if (mounted) Navigator.pop(context);
    }
  }

  void _handleDeleteAlbum(AlbumModel album) async {
    final userName = UserProvider.of(context)?.userName ?? "User";
    final response = await SocketService().sendRequest({
      'action': 'deleteAlbum',
      'username': userName,
      'title': album.title,
    });

    if (response['status'] == 'success') {
      widget.onDeleteAlbum(album);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          )
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
                        builder: (context) => AlbumDetailsScreen(album: album, allImages: widget.allImages),
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
  final List<ImageModel> allImages;

  const AlbumDetailsScreen({super.key, required this.album, required this.allImages});

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
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
          )
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
              ),
              itemCount: widget.album.images.length,
              itemBuilder: (context, index) {
                final img = widget.album.images[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(img.imageUrl, fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}