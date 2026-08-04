import 'package:flutter/material.dart';
import 'dart:convert';
import 'SocketService.dart';
import 'HomeScreen.dart'; 

class ImageDetailsScreen extends StatefulWidget {
  final ImageModel imageItem;
  final String currentUserName;
  final String currentAlbumTitle;
  final List<String> userAlbums;

  const ImageDetailsScreen({
    super.key,
    required this.imageItem,
    required this.currentUserName,
    this.currentAlbumTitle = '',
    this.userAlbums = const [],
  });

  @override
  State<ImageDetailsScreen> createState() => _ImageDetailsScreenState();
}

class _ImageDetailsScreenState extends State<ImageDetailsScreen> {
  late int _likeCount;
  late List<CommentModel> _comments;
  late List<String> _tags;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.imageItem.likes;
    _comments = List.from(widget.imageItem.comments);
    _tags = List.from(widget.imageItem.tags);
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
      widget.imageItem.likes = _likeCount;
    });

    await SocketService().sendRequest({
      'action': 'likeImage',
      'name': widget.imageItem.name,
      'username': widget.currentUserName,
    });
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = CommentModel(
      username: widget.currentUserName,
      text: text,
    );

    setState(() {
      _comments.add(newComment);
      widget.imageItem.comments.add(newComment);
      _commentController.clear();
    });

    await SocketService().sendRequest({
      'action': 'addComment',
      'name': widget.imageItem.name,
      'username': widget.currentUserName,
      'comment': text,
    });
  }

  void _addTag() async {
    final tagText = _tagController.text.trim();
    if (tagText.isEmpty) return;

    if (!_tags.contains(tagText)) {
      setState(() {
        _tags.add(tagText);
        widget.imageItem.tags.add(tagText);
        _tagController.clear();
      });

      await SocketService().sendRequest({
        'action': 'addTag',
        'name': widget.imageItem.name,
        'tag': tagText,
      });
    }
  }

  void _showMoveImageDialog() {
    final availableAlbums = widget.userAlbums
        .where((alb) => alb != widget.currentAlbumTitle)
        .toList();

    if (availableAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There isn\'t anyother album')),
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
                  Text('انتقال عکس', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(' Photo name: ${widget.imageItem.name}'),
                  const SizedBox(height: 16),
                  const Text('Select album\'s target'),
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

                    final response = await SocketService().moveImage(
                      username: widget.currentUserName,
                      sourceAlbum: widget.currentAlbumTitle,
                      targetAlbum: selectedAlbum,
                      imageName: widget.imageItem.name,
                    );

                    if (mounted) {
                      if (response['statusCode'] == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response['message'] ?? 'Photo moved successfully',
                            ),
                          ),
                        );
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response['message'] ?? 'Error transferring photo',
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

  Widget _buildImageWidget(String data) {
    if (data.isEmpty) return const Icon(Icons.broken_image, size: 100);
    String cleanData = data.replaceAll(RegExp(r'\s+'), '');

    if (cleanData.startsWith('http://') || cleanData.startsWith('https://')) {
      String formattedUrl = cleanData
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
      return Image.network(formattedUrl, fit: BoxFit.cover);
    }

    try {
      String base64Str =
          cleanData.contains(',') ? cleanData.split(',').last : cleanData;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.broken_image, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imageItem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_file_move_outlined),
            tooltip: 'Move to another album',
            onPressed: _showMoveImageDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: _buildImageWidget(widget.imageItem.imageUrl),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text(
                      '$_likeCount Likes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (widget.imageItem.caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.imageItem.caption,
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const Divider(height: 30),

            const Text(
              'Tags:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                ..._tags.map(
                  (tag) => Chip(
                    label: Text('#$tag'),
                    backgroundColor: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag...',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_task, color: Colors.blue),
                  onPressed: _addTag,
                ),
              ],
            ),

            const Divider(height: 30),

            const Text(
              'Comments:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      comment.username.isNotEmpty
                          ? comment.username[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(
                    comment.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(comment.text),
                );
              },
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}