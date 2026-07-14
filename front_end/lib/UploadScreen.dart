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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String? _selectedSourceMessage;

  void _pickFromGallery() {
    setState(() {
      _selectedSourceMessage = "Selected from Gallery (Mocked)";
      _urlController.text = "https://picsum.photos/id/1025/400/500";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image successfully picked from Gallery!')),
    );
  }

  void _takeWithCamera() {
    setState(() {
      _selectedSourceMessage = "Captured with Camera (Mocked)";
      _urlController.text = "https://picsum.photos/id/1011/400/500";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo captured successfully with Camera!')),
    );
  }

  void _submitUpload() {
    if (_formKey.currentState!.validate()) {
      final newImage = ImageMock(
        name: _nameController.text.trim(),
        caption: _captionController.text.trim(),
        imageUrl: _urlController.text.isNotEmpty ? _urlController.text : "https://picsum.photos/id/237/400/500",
        likes: 0,
        tags: ['New'],
        comments: [],
      );
      widget.onImageUploaded(newImage);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Image Name'),
                validator: (v) => v!.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _takeWithCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              if (_selectedSourceMessage != null) ...[
                const SizedBox(height: 10),
                Text(_selectedSourceMessage!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitUpload,
                child: const Text('Post Image'),
              )
            ],
          ),
        ),
      ),
    );
  }
}