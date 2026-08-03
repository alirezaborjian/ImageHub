import 'package:flutter/material.dart';
import 'ImageDetailsScreen.dart';
import 'SocketService.dart';

class CommentModel {
  final String userName;
  final String text;

  CommentModel({required this.userName, required this.text});
}

class ImageModel {
  final String name;
  final String caption;
  final String imageUrl;
  int likes;
  final List<String> tags;
  final List<CommentModel> comments;
  bool isLikedByMe;

  ImageModel({
    required this.name,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.tags,
    required this.comments,
    this.isLikedByMe = false,
  });
}

class HomeScreen extends StatefulWidget {
  final List<ImageModel> images;
  final String userName;
  final Function(ImageModel)? onImageDeleted;

  const HomeScreen({
    super.key,
    required this.images,
    required this.userName,
    this.onImageDeleted,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<ImageModel> allImages;
  List<ImageModel> filteredImages = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allImages = widget.images;
    filteredImages = allImages;
  }

  void _filterImages(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredImages = allImages;
      } else {
        filteredImages = allImages
            .where(
              (img) =>
                  img.name.toLowerCase().contains(query.toLowerCase()) ||
                  img.caption.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleLike(ImageModel item) async {
    final response = await SocketService().sendRequest({
      'action': 'likeImage',
      'name': item.name,
      'username': widget.userName,
    });

    if (response['statusCode'] == 200) {
      setState(() {
        if (item.isLikedByMe) {
          item.likes--;
          item.isLikedByMe = false;
        } else {
          item.likes++;
          item.isLikedByMe = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    allImages = widget.images;
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search images...',
                  border: InputBorder.none,
                ),
                onChanged: _filterImages,
              )
            : const Text('Gallery'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchController.clear();
                  filteredImages = allImages;
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: filteredImages.isEmpty
          ? const Center(child: Text('No images found.'))
          : ListView.builder(
              itemCount: filteredImages.length,
              itemBuilder: (context, index) {
                final item = filteredImages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDetailsScreen(
                                imageItem: item,
                                currentUserName: widget.userName,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Image.network(
                          item.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.caption),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleLike(item),
                              child: Row(
                                children: [
                                  Icon(
                                    item.isLikedByMe
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: item.isLikedByMe
                                        ? Colors.red
                                        : Colors.grey[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${item.likes}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 16),
                                const SizedBox(width: 4),
                                Text('${item.comments.length}'),
                              ],
                            ),
                          ],
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
