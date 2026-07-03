import 'package:flutter/material.dart';
import 'UploadScreen.dart';
import 'ImageDetailsScreen.dart';

class CommentMock {
  final String userName;
  final String text;

  CommentMock({required this.userName, required this.text});
}

class ImageMock {
  final String name;
  final String caption;
  final String imageUrl;
  int likes;
  final List<String> tags;
  final List<CommentMock> comments;
  bool isLikedByMe;

  ImageMock({
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
  final List<ImageMock> images;
  final String userName;
  final Function(ImageMock)? onImageDeleted; // ✅ اضافه شد برای حذف عکس

  const HomeScreen({
    super.key, 
    required this.images,
    required this.userName,
    this.onImageDeleted, // ✅ اضافه شد
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<ImageMock> allImages;
  List<ImageMock> filteredImages = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allImages = widget.images;
    filteredImages = List.from(allImages);
    searchController.addListener(_filterImages);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterImages);
    searchController.dispose();
    super.dispose();
  }

  void _filterImages() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredImages = List.from(allImages);
      } else {
        filteredImages = allImages.where((image) {
          return image.name.toLowerCase().contains(query) ||
              image.caption.toLowerCase().contains(query) ||
              image.tags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredImages = List.from(allImages);
      }
    });
  }

  // ✅ متد حذف عکس
  void _deleteImage(ImageMock image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Image',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete "${image.name}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // حذف از لیست اصلی
              setState(() {
                allImages.remove(image);
                filteredImages.remove(image);
              });
              
              // ✅ اگر callback وجود داشت، به والد اطلاع بده
              if (widget.onImageDeleted != null) {
                widget.onImageDeleted!(image);
              }
              
              Navigator.pop(context);
              
              // نمایش پیام موفقیت
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${image.name}" deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name, caption, or tag...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withAlpha(230),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            _filterImages();
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.black87),
              )
            : const Text(
                'Image Gallery',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
        backgroundColor: Colors.white.withAlpha(217),
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.black87,
            ),
            onPressed: _toggleSearch,
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
        child: Padding(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 20,
            left: 10,
            right: 10,
            bottom: 10,
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (allImages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No images available',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            Text(
              'Tap the + button to add some!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (isSearching && searchController.text.isNotEmpty && filteredImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different keyword',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredImages.length,
      itemBuilder: (context, index) {
        final imageItem = filteredImages[index];
        return _buildImageCard(imageItem);
      },
    );
  }

  Widget _buildImageCard(ImageMock item) {
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
        ).then((_) {
          if (mounted) setState(() {});
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ✅ دکمه ۳ نقطه برای حذف
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteImage(item);
                          }
                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 20,
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        offset: const Offset(0, 0),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.caption,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLikeButton(item),
                      _buildCommentCounter(item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(ImageMock item) {
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
          Text(
            '${item.likes}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCounter(ImageMock item) {
    return Row(
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${item.comments.length}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}