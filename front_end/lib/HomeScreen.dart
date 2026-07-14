import 'package:flutter/material.dart';
import 'UploadScreen.dart';
import 'ImageDetailsScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: filteredImages.isEmpty
          ? const Center(child: Text('No images found'))
          : ListView.builder(
              itemCount: filteredImages.length,
              itemBuilder: (context, index) {
                final item = filteredImages[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.network(item.imageUrl, fit: BoxFit.cover),
                      ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.caption),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLikeButton(item),
                            const SizedBox(width: 8),
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

  Widget _buildLikeButton(ImageModel item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (item.isLikedByMe) {
            item.likes--;
            item.isLikedByMe = false;
          } else {
            item.likes++;
            item.isLikedByMe = true;
          }
        });
      },
      child: Row(
        children: [
          Icon(
            item.isLikedByMe ? Icons.favorite : Icons.favorite_border,
            color: item.isLikedByMe ? Colors.red : Colors.grey[600],
            size: 18,
          ),
          const SizedBox(width: 4),
          Text('${item.likes}'),
        ],
      ),
    );
  }
}