import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'ImageDetailsScreen.dart';
  

class AlbumMock {
  final String title;
  String coverUrl; // ✅ اضافه شد
  final List<ImageMock> images;

  AlbumMock({
    required this.title,
    required this.images,
    this.coverUrl = '',
  });
}

class AlbumScreen extends StatefulWidget {
  final List<AlbumMock> albums;
  final Function(String) onCreateAlbum;
  final Function(AlbumMock, ImageMock) onRemoveImageFromAlbum;
  final Function(AlbumMock, String) onUpdateCover; // ✅ برای آپدیت کاور
  final List<ImageMock> allImages; // ✅ لیست همه عکس‌ها برای انتخاب

  const AlbumScreen({
    super.key,
    required this.albums,
    required this.onCreateAlbum,
    required this.onRemoveImageFromAlbum,
    required this.onUpdateCover,
    required this.allImages,
  });

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final TextEditingController _albumTitleController = TextEditingController();

  @override
  void dispose() {
    _albumTitleController.dispose();
    super.dispose();
  }

  void _showCreateAlbumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Album'),
        content: TextField(
          controller: _albumTitleController,
          decoration: const InputDecoration(
            hintText: 'Album Title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_albumTitleController.text.trim().isNotEmpty) {
                widget.onCreateAlbum(_albumTitleController.text.trim());
                _albumTitleController.clear();
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Albums',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.black87),
            onPressed: _showCreateAlbumDialog,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: widget.albums.isEmpty
            ? const Center(
                child: Text(
                  'No albums created yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.albums.length,
                itemBuilder: (context, index) {
                  final album = widget.albums[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: album.coverUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  album.coverUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.photo_album, color: Colors.grey);
                                  },
                                ),
                              )
                            : album.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      album.images.first.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.photo_album, color: Colors.grey),
                      ),
                      title: Text(
                        album.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text('${album.images.length} Images'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbumDetailsScreen(
                              album: album,
                              allImages: widget.allImages,
                              onRemoveImage: (img) {
                                widget.onRemoveImageFromAlbum(album, img);
                                setState(() {});
                              },
                              onUpdateCover: (coverUrl) {
                                widget.onUpdateCover(album, coverUrl);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AlbumDetailsScreen extends StatefulWidget {
  final AlbumMock album;
  final List<ImageMock> allImages; // ✅ لیست همه عکس‌ها
  final Function(ImageMock) onRemoveImage;
  final Function(String) onUpdateCover; // ✅ برای آپدیت کاور

  const AlbumDetailsScreen({
    super.key,
    required this.album,
    required this.allImages,
    required this.onRemoveImage,
    required this.onUpdateCover,
  });

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  String _sortBy = 'NAME';
  
  // ✅ لیست عکس‌های موجود در آلبوم
  List<ImageMock> get _albumImages => widget.album.images;
  
  // ✅ لیست عکس‌های موجود در گالری که در آلبوم نیستند
  List<ImageMock> get _availableImages {
    final albumImageIds = _albumImages.map((e) => e.hashCode).toSet();
    return widget.allImages.where((img) => !albumImageIds.contains(img.hashCode)).toList();
  }

  void _sortImages() {
    setState(() {
      if (_sortBy == 'NAME') {
        _albumImages.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortBy == 'LIKES') {
        _albumImages.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (_sortBy == 'DATE') {
        // اگر تاریخ داشتید
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sortImages();
  }

  // ✅ دیالوگ انتخاب کاور آلبوم
  void _showChangeCoverDialog() {
    if (_albumImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add some images first to set a cover!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Cover Image'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _albumImages.length,
            itemBuilder: (context, index) {
              final img = _albumImages[index];
              return GestureDetector(
                onTap: () {
                  widget.onUpdateCover(img.imageUrl);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cover updated to: ${img.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.album.coverUrl == img.imageUrl
                          ? Colors.blue
                          : Colors.transparent,
                      width: 3,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(img.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: widget.album.coverUrl == img.imageUrl
                      ? const Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 24,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onUpdateCover('');
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Remove Cover'),
          ),
        ],
      ),
    );
  }

  // ✅ دیالوگ افزودن عکس به آلبوم از گالری
  void _showAddImagesDialog() {
    if (_availableImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more images available to add!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Images to Album'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: _availableImages.length,
            itemBuilder: (context, index) {
              final img = _availableImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _albumImages.add(img);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${img.name}" added to album'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _sortImages();
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          img.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          img.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.title),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          // ✅ دکمه تغییر کاور آلبوم
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _showChangeCoverDialog,
            tooltip: 'Change Album Cover',
          ),
          // ✅ دکمه افزودن عکس
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _showAddImagesDialog,
            tooltip: 'Add Images from Gallery',
          ),
          // ✅ دکمه مرتب‌سازی
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              _sortBy = value;
              _sortImages();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'NAME', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'LIKES', child: Text('Sort by Likes')),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _albumImages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'This album is empty.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add images from gallery',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddImagesDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _albumImages.length,
                itemBuilder: (context, index) {
                  final img = _albumImages[index];
                  return _buildImageCard(img);
                },
              ),
      ),
    );
  }

  // ✅ ویجت کارت عکس با تمام امکانات HomeScreen
  Widget _buildImageCard(ImageMock item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageDetailsScreen(
              imageItem: item,
              currentUserName: 'User', // اسم کاربر رو از Provider بگیر
            ),
          ),
        ).then((_) {
          if (mounted) setState(() {});
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ تصویر
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            // ✅ اطلاعات پایین
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ✅ منوی سه نقطه برای حذف از آلبوم
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'remove') {
                            _showRemoveConfirmation(item);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(item);
                          }
                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 20,
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Remove from Album',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Permanently',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        offset: const Offset(0, 0),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.caption,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLikeButton(item),
                      _buildCommentCounter(item),
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

  // ✅ دکمه لایک (مثل HomeScreen)
  Widget _buildLikeButton(ImageMock item) {
    return GestureDetector(
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
            item.isLikedByMe ? Icons.favorite : Icons.favorite_border,
            color: item.isLikedByMe ? Colors.red : Colors.grey[600],
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${item.likes}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ شمارنده کامنت (مثل HomeScreen)
  Widget _buildCommentCounter(ImageMock item) {
    return Row(
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${item.comments.length}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // ✅ دیالوگ حذف از آلبوم
  void _showRemoveConfirmation(ImageMock item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove from Album',
          style: TextStyle(color: Colors.orange),
        ),
        content: Text(
          'Remove "${item.name}" from this album?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveImage(item);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.name}" removed from album'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ✅ دیالوگ حذف دائمی عکس
  void _showDeleteConfirmation(ImageMock item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Image',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${item.name}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // حذف از آلبوم
              widget.onRemoveImage(item);
              
              // حذف از گالری اصلی (از طریق callback به MainWrapper)
              // این کار باید در MainWrapper انجام بشه
              // برای این کار باید یک callback جدید اضافه کنیم
              
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.name}" deleted permanently'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}