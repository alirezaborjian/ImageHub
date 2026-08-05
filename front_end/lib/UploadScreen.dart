import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'HomeScreen.dart';
import 'SocketService.dart';

class UploadScreen extends StatefulWidget {
  final String currentUserName;
  final Function(ImageModel) onImageUploaded;

  const UploadScreen({
    super.key,
    required this.currentUserName,
    required this.onImageUploaded,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();
    final tagsInput = _tagsController.text.trim();

    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
      }
      return;
    }

    if (title.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an image title')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      List<String> tagsList = tagsInput.isNotEmpty
          ? tagsInput.split(',').map((e) => e.trim()).toList()
          : [];

      final response = await SocketService().sendRequest({
        'action': 'uploadImage',
        'username': widget.currentUserName,
        'title': title,
        'caption': caption,
        'tags': tagsList,
        'imageData': base64Image,
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return {
            'statusCode': 408,
            'message': 'Connection timed out',
          };
        },
      );

      if (response['statusCode'] == 200) {
        final newImage = ImageModel(
          name: title,
          caption: caption,
          imageUrl: base64Image,
          likes: 0,
          tags: tagsList,
          comments: [],
        );

        widget.onImageUploaded(newImage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to upload image'),
            ),
          );
        }
      }
    } catch (e) {
      print('Exception in upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading image to server...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to select an image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Image Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      labelText: 'Caption',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upload Image',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}