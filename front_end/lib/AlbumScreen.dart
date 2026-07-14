import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'UploadScreen.dart';

class AlbumMock {
  final String title;
  String coverUrl;
  final List<ImageMock> images;

  AlbumMock({
    required this.title,
    required this.images,
    this.coverUrl = '',
  });
}

class AlbumScreen extends StatefulWidget {
  final List<AlbumMock> albums;
  final Function(String) onCreateAlbum;
  final Function(AlbumMock, ImageMock) onRemoveImageFromAlbum;
  final Function(AlbumMock, String) onUpdateCover;
  final Function(AlbumMock) onDeleteAlbum;
  final Function(AlbumMock, AlbumMock, ImageMock) onMoveImageToAnotherAlbum;
  final List<ImageMock> allImages;

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

  void _showCreateAlbumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Album'),
        content: TextField(
          controller: _albumTitleController,
          decoration: const InputDecoration(labelText: 'Album Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = _albumTitleController.text.trim();
              if (title.isNotEmpty) {
                widget.onCreateAlbum(title);
                _albumTitleController.clear();
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.albums.isEmpty
          ? const Center(child: Text('No albums created yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.albums.length,
              itemBuilder: (context, index) {
                final album = widget.albums[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(album.title),
                    subtitle: Text('${album.images.length} Photos'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        widget.onDeleteAlbum(album);
                        setState(() {});
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlbumDetailsScreen(
                            album: album,
                            allAlbums: widget.albums,
                            onRemoveImageFromAlbum: (img) => widget.onRemoveImageFromAlbum(album, img),
                            onMoveImage: (target, img) => widget.onMoveImageToAnotherAlbum(album, target, img),
                            onSetCover: (url) => widget.onUpdateCover(album, url),
                            allImages: widget.allImages,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAlbumDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AlbumDetailsScreen extends StatefulWidget {
  final AlbumMock album;
  final List<AlbumMock> allAlbums;
  final Function(ImageMock) onRemoveImageFromAlbum;
  final Function(AlbumMock, ImageMock) onMoveImage;
  final Function(String) onSetCover;
  final List<ImageMock> allImages;

  const AlbumDetailsScreen({
    super.key,
    required this.album,
    required this.allAlbums,
    required this.onRemoveImageFromAlbum,
    required this.onMoveImage,
    required this.onSetCover,
    required this.allImages,
  });

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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: widget.album.images.length,
              itemBuilder: (context, index) {
                final img = widget.album.images[index];
                return Card(
                  child: Image.network(img.imageUrl, fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}