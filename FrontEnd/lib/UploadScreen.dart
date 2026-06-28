import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class UploadScreen extends StatefulWidget {
  final Function(ImageMock) onImageUploaded;
  
  const UploadScreen({
    super.key,
    required this.onImageUploaded,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _captionController = new TextEditingController();
  final TextEditingController _tagController = new TextEditingController();
  final TextEditingController _urlController = new TextEditingController();

  final List<String> _tags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _captionController.dispose();
    _tagController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tagText = _tagController.text.trim();
    if (tagText.isNotEmpty && !_tags.contains(tagText)) {
      setState(() {
        _tags.add(tagText);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _submitUpload() {
    if (_formKey.currentState!.validate()) {
      final newImage = ImageMock(
        name: _nameController.text.trim(),
        caption: _captionController.text.trim(),
        imageUrl: _urlController.text.trim().isNotEmpty 
        ? _urlController.text.trim()
        : "https://picsum.photos/id/237/400/500", 
        likes: 0, 
        tags: List.from(_tags), 
        comments: [],
        );

        widget.onImageUploaded(newImage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully.'))
        );

        Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
