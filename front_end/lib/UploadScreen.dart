import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _selectedImage;
  String? _base64Data;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Data = base64Encode(bytes);
      });
    }
  }

  void _submitUpload() async {
    if (_formKey.currentState!.validate()) {
      if (_base64Data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final socketService = SocketService();
      final userProvider = UserProvider.of(context);
      final currentUserName = userProvider?.userName ?? "User";

      Map<String, dynamic> request = {
        'action': 'uploadImage',
        'name': _nameController.text.trim(),
        'caption': _captionController.text.trim(),
        'base64Data': _base64Data,
        'username': currentUserName,
      };

      final response = await socketService.sendRequest(request);

      setState(() => _isLoading = false);

      if (response['statusCode'] == 200) {
        final serverImg = response['payload'];
        final newImg = ImageModel(
          name: serverImg != null
              ? (serverImg['name'] ?? _nameController.text.trim())
              : _nameController.text.trim(),
          caption: serverImg != null
              ? (serverImg['caption'] ?? _captionController.text.trim())
              : _captionController.text.trim(),
          imageUrl: serverImg != null ? (serverImg['imageUrl'] ?? '') : '',
          likes: 0,
          tags: [],
          comments: [],
        );
        widget.onImageUploaded(newImg);
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Upload failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to select an image'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Image Name',
                      ),
                      validator: (v) => v!.isEmpty ? 'Please enter name' : null,
                    ),
                    TextFormField(
                      controller: _captionController,
                      decoration: const InputDecoration(labelText: 'Caption'),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitUpload,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('Post Image'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
