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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Pinterest...',
                  border: InputBorder.none,
                ),
                onChanged: _filterImages,
              )
            : const Text(
                'Explore',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
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
          ? const Center(child: Text('No pins found.'))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredImages.length,
              itemBuilder: (context, index) {
                final item = filteredImages[index];
                return GestureDetector(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            item.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleLike(item),
                            child: Icon(
                              item.isLikedByMe
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: item.isLikedByMe
                                  ? Colors.red
                                  : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.likes}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          if (widget.onImageDeleted != null)
                            GestureDetector(
                              onTap: () => widget.onImageDeleted!(item),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 6.0),
                                child: Icon(
                                  Icons.more_horiz,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
