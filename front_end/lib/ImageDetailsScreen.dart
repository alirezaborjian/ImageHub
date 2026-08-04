import 'dart:convert';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'SocketService.dart';

class ImageDetailsScreen extends StatefulWidget {
  final ImageModel imageItem;
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

  void _submitComment() async {
    if (_formKey.currentState!.validate()) {
      final commentText = _commentController.text.trim();

      final response = await SocketService().sendRequest({
        'action': 'addComment',
        'name': widget.imageItem.name,
        'username': widget.currentUserName,
        'text': commentText,
      });

      if (response['statusCode'] == 200) {
        setState(() {
          widget.imageItem.comments.add(
            CommentModel(userName: widget.currentUserName, text: commentText),
          );
        });
        _commentController.clear();
        if (mounted) {
          FocusScope.of(context).unfocus();
        }
      }
    }
  }

  Widget _buildImageWidget(String url) {
    if (url.trim().isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
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
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            );
          },
        );
      } catch (_) {
        return Container(
          height: 300,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        );
      }
    }

    return Image.network(
      cleanUrl,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 300,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.imageItem;
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(item.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.caption,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: item.tags
                        .map((t) => Chip(label: Text('#$t')))
                        .toList(),
                  ),
                  const Divider(height: 30),
                  Text(
                    'Comments (${item.comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.comments.length,
                    itemBuilder: (context, idx) {
                      final c = item.comments[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          c.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(c.text),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: UnderlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Comment cannot be empty'
                                    : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color.fromRGBO(143, 148, 251, 1),
                          ),
                          onPressed: _submitComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}