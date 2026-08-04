import 'package:flutter/material.dart';
import 'SocketService.dart';
import 'HomeScreen.dart';

class AlbumDetailsScreen extends StatefulWidget {
  final String albumTitle;
  final String currentUserName;
  final List<ImageModel> albumImages;
  final List<String> allUserAlbums;

  const AlbumDetailsScreen({
    super.key,
    required this.albumTitle,
    required this.currentUserName,
    required this.albumImages,
    required this.allUserAlbums,
  });

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  late List<ImageModel> _images;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.albumImages);
  }

  /// Dialog to select the target album and perform the image move operation
  void _showMoveImageDialog(ImageModel image) {
    // Exclude current album from available choices
    final availableAlbums = widget.allUserAlbums
        .where((alb) => alb != widget.albumTitle)
        .toList();

    if (availableAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other albums available to move to.')),
      );
      return;
    }

    String selectedAlbum = availableAlbums.first;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.drive_file_move, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Move Image', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image: ${image.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Select Target Album:'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedAlbum,
                    isExpanded: true,
                    items: availableAlbums.map((String albumName) {
                      return DropdownMenuItem<String>(
                        value: albumName,
                        child: Text(albumName),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          selectedAlbum = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Move'),
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    // Send move request to Socket Server
                    final response = await SocketService().moveImage(
                      username: widget.currentUserName,
                      sourceAlbum: widget.albumTitle,
                      targetAlbum: selectedAlbum,
                      imageName: image.name,
                    );

                    if (mounted) {
                      if (response['statusCode'] == 200) {
                        setState(() {
                          _images.removeWhere((img) => img.name == image.name);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response['message'] ?? 'Image moved successfully.',
                            ),
                          ),
                        );

                        // Pop with true to notify parent screen to refresh data if needed
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response['message'] ?? 'Failed to move image.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Album: ${widget.albumTitle}'),
      ),
      body: _images.isEmpty
          ? const Center(child: Text('No images found in this album.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      // Image Display
                      Positioned.fill(
                        child: Image.network(
                          image.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      // Bottom bar with move action icon
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  image.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.drive_file_move_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Move Image',
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () => _showMoveImageDialog(image),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}