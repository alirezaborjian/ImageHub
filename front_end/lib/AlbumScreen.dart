import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'UploadScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.albums.isEmpty
          ? const Center(child: Text('No albums created yet'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.albums.length,
              itemBuilder: (context, index) {
                final album = widget.albums[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailsScreen(
                          album: album,
                          allImages: widget.allImages,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: album.coverUrl.isNotEmpty
                              ? Image.network(album.coverUrl, fit: BoxFit.cover)
                              : const Icon(Icons.collections, size: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(album.title, style: const TextStyle(fontWeight: FontWeight.bold)),
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