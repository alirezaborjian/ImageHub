import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'SocketService.dart';
import 'UserProvider.dart';

class UploadScreen extends StatefulWidget {
  final Function(ImageModel) onImageUploaded;

  const UploadScreen({super.key, required this.onImageUploaded});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final String _dummyBase64Data =
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

  void _submitUpload() async {
    if (_formKey.currentState!.validate()) {
      final socketService = SocketService();
      final userProvider = UserProvider.of(context);
      final currentUserName = userProvider?.userName ?? "User";

      Map<String, dynamic> request = {
        'action': 'uploadImage',
        'name': _nameController.text.trim(),
        'caption': _captionController.text.trim(),
        'base64Data': _dummyBase64Data,
        'username': currentUserName,
      };

      final response = await socketService.sendRequest(request);

      if (response['statusCode'] == 200) {
        final serverImg = response['payload'];
        final newImg = ImageModel(
          name: serverImg['name'] ?? _nameController.text.trim(),
          caption: serverImg['caption'] ?? _captionController.text.trim(),
          imageUrl: serverImg['imageUrl'] ?? 'https://picsum.photos/400/500',
          likes: 0,
          tags: [],
          comments: [],
        );
        widget.onImageUploaded(newImg);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitUpload,
                child: const Text('Post Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
