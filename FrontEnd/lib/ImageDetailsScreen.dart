import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class ImageDetailsScreen extends StatefulWidget {
  final ImageMock imageItem;
  final String currentUserName;

  const ImageDetailsScreen({
    super.key,
    required this.imageItem,
    required this.currentUserName,
  });

  @override
  State<ImageDetailsScreen> createState() => _ImageDetailsScreenState();
}

class _ImageDetailsScreenState extends State<ImageDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.imageItem.comments.add(
          CommentMock(
            userName: widget.currentUserName,
            text: _commentController.text.trim(),
          ),
        );
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.imageItem;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 300,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, StackTrace) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            item.isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item.isLikedByMe
                                ? Colors.red
                                : Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.likes} Like',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 24,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '{item.comments.length} Viewpoint',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (item.caption.isNotEmpty) ...[
                  Text(
                    item.caption,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                ],
                if (item.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: item.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        backgroundColor: Colors.grey[100],
                        labelStyle: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 13,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                const Divider(height: 32),
                const Text(
                  'User comments',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (item.comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'There are no comments yet. Be the first to comment!',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.comments.length,
                    itemBuilder: (context, index) {
                      final comment = item.comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[200],
                              radius: 18,
                              child: Text(
                                comment.userName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
