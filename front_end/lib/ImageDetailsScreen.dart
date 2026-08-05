import 'dart:convert';
import 'package:flutter/material.dart';
import 'SocketService.dart';
import 'HomeScreen.dart';

class ImageDetailsScreen extends StatefulWidget {
  final ImageModel image;
  final String currentUserName;
  final List<String> allUserAlbums;

  const ImageDetailsScreen({
    super.key,
    required this.image,
    required this.currentUserName,
    required this.allUserAlbums,
  });

  @override
  State<ImageDetailsScreen> createState() => _ImageDetailsScreenState();
}

class _ImageDetailsScreenState extends State<ImageDetailsScreen> {
  late int _likeCount;
  late bool _isLikedByMe;
  bool _isLiking = false;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likeCount = widget.image.likes;
    _isLikedByMe = widget.image.likedByUsers.contains(widget.currentUserName);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _handleLikeToggle() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      if (_isLikedByMe) {
        _isLikedByMe = false;
        _likeCount--;
        widget.image.likedByUsers.remove(widget.currentUserName);
      } else {
        _isLikedByMe = true;
        _likeCount++;
        widget.image.likedByUsers.add(widget.currentUserName);
      }
      widget.image.likes = _likeCount;
    });

    final response = await SocketService().toggleLike(
      username: widget.currentUserName,
      imageName: widget.image.name,
    );

    if (mounted) {
      setState(() {
        _isLiking = false;
      });

      if (response['statusCode'] != 200) {
        setState(() {
          if (_isLikedByMe) {
            _isLikedByMe = false;
            _likeCount--;
            widget.image.likedByUsers.remove(widget.currentUserName);
          } else {
            _isLikedByMe = true;
            _likeCount++;
            widget.image.likedByUsers.add(widget.currentUserName);
          }
          widget.image.likes = _likeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to toggle like')),
        );
      }
    }
  }

  Future<void> _handleAddComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final response = await SocketService().addComment(
      username: widget.currentUserName,
      imageName: widget.image.name,
      comment: text,
    );

    if (mounted) {
      if (response['statusCode'] == 200) {
        setState(() {
          widget.image.comments.add(
            CommentModel(username: widget.currentUserName, text: text),
          );
          _commentController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to add comment')),
        );
      }
    }
  }

  Future<void> _handleAddTag() async {
    final text = _tagController.text.trim();
    if (text.isEmpty) return;

    final response = await SocketService().addTag(
      username: widget.currentUserName,
      imageName: widget.image.name,
      tag: text,
    );

    if (mounted) {
      if (response['statusCode'] == 200) {
        setState(() {
          widget.image.tags.add(text);
          _tagController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to add tag')),
        );
      }
    }
  }

  void _showMoveDialog() {
    if (widget.allUserAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other albums available.')),
      );
      return;
    }

    String selectedAlbum = widget.allUserAlbums.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Move Image to Album'),
            content: DropdownButton<String>(
              value: selectedAlbum,
              isExpanded: true,
              items: widget.allUserAlbums.map((album) {
                return DropdownMenuItem(value: album, child: Text(album));
              }).toList(),
              onChanged: (val) {
                if (val != null) setDialogState(() => selectedAlbum = val);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final res = await SocketService().moveImage(
                    username: widget.currentUserName,
                    sourceAlbum: widget.image.album ?? 'Default',
                    targetAlbum: selectedAlbum,
                    imageName: widget.image.name,
                  );

                  if (mounted) {
                    if (res['statusCode'] == 200) {
                      setState(() {
                        widget.image.album = selectedAlbum;
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res['message'] ?? 'Operation completed')),
                    );
                  }
                },
                child: const Text('Move'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String data) {
    if (data.isEmpty) return const Icon(Icons.broken_image, size: 100);

    String cleanData = data.replaceAll(RegExp(r'\s+'), '');
    if (cleanData.startsWith('http://') || cleanData.startsWith('https://')) {
      String formattedUrl = cleanData
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
      return Image.network(
        formattedUrl,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
      );
    }

    try {
      String base64Str = cleanData.contains(',') ? cleanData.split(',').last : cleanData;
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
      );
    } catch (e) {
      return const Icon(Icons.broken_image, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.image.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_file_move_outlined),
            tooltip: 'Move to Album',
            onPressed: _showMoveDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(widget.image.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isLikedByMe ? Icons.favorite : Icons.favorite_border,
                          color: _isLikedByMe ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        onPressed: _handleLikeToggle,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likeCount Likes',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.image.tags
                        .map((tag) => Chip(label: Text('#$tag')))
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(hintText: 'Add a tag'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_location_alt_outlined),
                        onPressed: _handleAddTag,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.image.comments.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${c.username}: ${c.text}'),
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(hintText: 'Write a comment'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _handleAddComment,
                      ),
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
}