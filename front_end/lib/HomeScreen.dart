import 'dart:convert';
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
  String selectedSortOption = 'Default';

  @override
  void initState() {
    super.initState();
    allImages = widget.images;
    filteredImages = List.from(allImages);
  }

  void _filterImages(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredImages = List.from(allImages);
      } else {
        filteredImages = allImages
            .where(
              (img) =>
                  img.name.toLowerCase().contains(query.toLowerCase()) ||
                  img.caption.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      _applySort(selectedSortOption);
    });
  }

  void _applySort(String criteria) {
    setState(() {
      selectedSortOption = criteria;
      if (criteria == 'Most Liked') {
        filteredImages.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (criteria == 'Alphabetical') {
        filteredImages.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (criteria == 'Default') {
        if (searchController.text.isEmpty) {
          filteredImages = List.from(allImages);
        } else {
          filteredImages = allImages
              .where(
                (img) =>
                    img.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                    img.caption.toLowerCase().contains(searchController.text.toLowerCase()),
              )
              .toList();
        }
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
      if (mounted) {
        setState(() {
          if (item.isLikedByMe) {
            item.likes--;
            item.isLikedByMe = false;
          } else {
            item.likes++;
            item.isLikedByMe = true;
          }
          if (selectedSortOption == 'Most Liked') {
            _applySort('Most Liked');
          }
        });
      }
    }
  }

  Widget _buildImageWidget(String url) {
    if (url.trim().isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    String cleanUrl = url.trim().replaceAll('\n', '').replaceAll('\r', '');

    bool isBase64 = cleanUrl.startsWith('data:image') ||
        (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://'));

    if (isBase64) {
      try {
        final base64Str = cleanUrl.contains(',') ? cleanUrl.split(',').last : cleanUrl;
        return Image.memory(
          base64Decode(base64Str),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      } catch (_) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    }

    return Image.network(
      cleanUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: _applySort,
            itemBuilder: (BuildContext context) {
              return {'Default', 'Most Liked', 'Alphabetical'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      if (selectedSortOption == choice)
                        const Icon(Icons.check, size: 18, color: Color.fromRGBO(143, 148, 251, 1))
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(choice),
                    ],
                  ),
                );
              }).toList();
            },
          ),
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
                  _filterImages('');
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
                          child: _buildImageWidget(item.imageUrl),
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