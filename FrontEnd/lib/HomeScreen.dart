import 'package:flutter/material.dart';

class CommentMock {
  final String userName;
  final String text;

  CommentMock({
    required this.userName,
    required this.text,
  });
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

  const HomeScreen({
    super.key,
    required this.images,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Image Gallery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            final imageItem = widget.images[index];
            return _buildImageCard(imageItem);
          },
        ),
      ),
    );
  }

  Widget _buildImageCard(ImageMock item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                fit: BoxFit.cover,
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
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                    GestureDetector(
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
                    ),
                    Row(
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
final List<ImageMock> dummyImages = [
  ImageMock(
    name: 'Beautiful Nature',
    caption: 'A fresh morning inside the deep woods and green trees.',
    imageUrl: 'https://picsum.photos/id/10/400/600',
    likes: 145,
    tags: ['nature', 'forest', 'travel'],
    comments: [],
  ),
  ImageMock(
    name: 'Mountain Trekking',
    caption: 'Amazing snowy peaks under the clear blue sky.',
    imageUrl: 'https://picsum.photos/id/29/400/500',
    likes: 92,
    tags: ['mountain', 'snow', 'adventure'],
    comments: [
      CommentMock(userName: 'Reza', text: 'Stunning capture!'),
    ],
  ),
  ImageMock(
    name: 'Ocean Waves',
    caption: 'Calm ocean waves touching the sandy shores at sunset.',
    imageUrl: 'https://picsum.photos/id/37/400/500',
    likes: 210,
    tags: ['beach', 'sunset', 'sea'],
    comments: [],
  ),
];