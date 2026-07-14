import 'package:flutter/material.dart';
import 'HomeScreen.dart';

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

  void _submitComment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.imageItem.comments.add(
          CommentModel(
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
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(item.imageUrl, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.caption, style: const TextStyle(fontSize: 16)),
                  const Divider(height: 32),
                  const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.comments.length,
                    itemBuilder: (context, idx) {
                      final c = item.comments[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            validator: (value) => value == null || value.trim().isEmpty ? 'Comment cannot be empty' : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color.fromRGBO(143, 148, 251, 1)),
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