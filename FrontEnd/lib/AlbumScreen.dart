import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class AlbumMock {
  final String title;
  final List<ImageMock> images;

  AlbumMock({
    required this.title,
    required this.images,
  });
}

class AlbumScreen extends StatefulWidget {
  final List<AlbumMock> albums;
  final Function(String) onCreateAlbum;
  final Function(AlbumMock, ImageMock) onRemoveImageFromAlbum;

  const AlbumScreen({
    super.key,
    required this.albums,
    required this.onCreateAlbum,
    required this.onRemoveImageFromAlbum,
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

  void _showCreateAlbumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Album'),
        content: TextField(
          controller: _albumTitleController,
          decoration: const InputDecoration(
            hintText: 'Album Title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_albumTitleController.text.trim().isNotEmpty) {
                widget.onCreateAlbum(_albumTitleController.text.trim());
                _albumTitleController.clear();
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Albums',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.black87),
            onPressed: _showCreateAlbumDialog,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: widget.albums.isEmpty
            ? const Center(
                child: Text(
                  'No albums created yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.albums.length,
                itemBuilder: (context, index) {
                  final album = widget.albums[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: album.images.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  album.images.first.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.photo_album, color: Colors.grey),
                      ),
                      title: Text(
                        album.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text('${album.images.length} Images'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbumDetailsScreen(
                              album: album,
                              onRemoveImage: (img) {
                                widget.onRemoveImageFromAlbum(album, img);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AlbumDetailsScreen extends StatefulWidget {
  final AlbumMock album;
  final Function(ImageMock) onRemoveImage;

  const AlbumDetailsScreen({
    super.key,
    required this.album,
    required this.onRemoveImage,
  });

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  String _sortBy = 'NAME';

  void _sortImages() {
    setState(() {
      if (_sortBy == 'NAME') {
        widget.album.images.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'LIKES') {
        widget.album.images.sort((a, b) => b.likes.compareTo(a.likes));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sortImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.title),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              _sortBy = value;
              _sortImages();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'NAME', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'LIKES', child: Text('Sort by Likes')),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: widget.album.images.isEmpty
            ? const Center(
                child: Text('This album is empty.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: widget.album.images.length,
                itemBuilder: (context, index) {
                  final img = widget.album.images[index];
                  return Stack(
                    children: [
                      Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: Image.network(img.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                img.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          radius: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () {
                              widget.onRemoveImage(img);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}