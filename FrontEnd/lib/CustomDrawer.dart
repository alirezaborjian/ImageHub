import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserProvider.dart';
import 'UploadScreen.dart';
import 'HomeScreen.dart';
import 'LoginAndSignUp.dart';

class CustomDrawer extends StatelessWidget {

  //  تعریف Callback های ناوبری
 
  final VoidCallback? onLogout;
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToAlbums;

  const CustomDrawer({
    super.key, 
    this.onLogout,
    this.onNavigateToHome,
    this.onNavigateToAlbums,
  });

  String _calculateTotalLikes(UserProvider provider) {
    int totalLikes = 0;
    for (var image in provider.allImages) {
      totalLikes += image.likes;
    }
    return totalLikes.toString();
  }

  // UI 

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProvider.of(context)!;
    final userName = userProvider.userName;
    final totalAlbums = userProvider.allAlbums.length;
    final totalImages = userProvider.allImages.length;
    final avatarUrl = userProvider.avatarUrl;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(143, 148, 251, 0.1),
              Color.fromRGBO(143, 148, 251, 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            //  هدر منو - نمایش آواتار، نام کاربری و وضعیت آنلاین
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(143, 148, 251, 1),
                    Color.fromRGBO(143, 148, 251, 0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // آواتار دایره‌ای (تصویر یا حرف اول نام)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: avatarUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarUrl.isEmpty
                          ? Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(143, 148, 251, 1),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // نام کاربری
                    Text(
                      userName.isNotEmpty ? userName : 'Guest User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // وضعیت آنلاین
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            //     نمایش تعداد تصاویر، آلبوم‌ها و لایک‌ها
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.photo_library,
                    value: '$totalImages',
                    label: 'Photos',
                  ),
                  _buildStatItem(
                    icon: Icons.collections_bookmark,
                    value: '$totalAlbums',
                    label: 'Albums',
                  ),
                  _buildStatItem(
                    icon: Icons.favorite,
                    value: _calculateTotalLikes(userProvider),
                    label: 'Likes',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),
 
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  //  دکمه رفتن به صفحه اصلی
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigateToHome != null) {
                        onNavigateToHome!();
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
                  //  دکمه رفتن به صفحه آلبوم‌ها
                  _buildDrawerItem(
                    icon: Icons.collections_bookmark,
                    title: 'My Albums',
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigateToAlbums != null) {
                        onNavigateToAlbums!();
                      } else {
                        Navigator.pushReplacementNamed(context, '/albums');
                      }
                    },
                  ),
                  //  دکمه آپلود تصویر
                  _buildDrawerItem(
                    icon: Icons.add_a_photo,
                    title: 'Upload Photo',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadScreen(
                            onImageUploaded: (newImage) {
                              final provider = UserProvider.of(context);
                              if (provider != null) {
                                final updatedImages = List<ImageMock>.from(provider.allImages)
                                  ..add(newImage);
                                provider.updateImages(updatedImages);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Image uploaded successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 20, thickness: 1),
                  //  دکمه تغییر رمز عبور
                  _buildDrawerItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.pop(context);
                      _showChangePasswordDialog(context);
                    },
                  ),
                  //  دکمه ویرایش پروفایل
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pop(context);
                      _showEditProfileDialog(context);
                    },
                  ),
                  const Divider(height: 20, thickness: 1),
                  //  دکمه حذف حساب کاربری 
                  _buildDrawerItem(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteAccountDialog(context);
                    },
                  ),
                  //  دکمه خروج از حساب 
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _performLogout(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  //   نسخه برنامه
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'App Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
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
  //  ساخت آیتم آماری (آیکون + عدد + برچسب)
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color.fromRGBO(143, 148, 251, 1), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  //  ساخت آیتم منو (آیکون + عنوان + فلش)
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color.fromRGBO(143, 148, 251, 1)),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
      hoverColor: const Color.fromRGBO(143, 148, 251, 0.1),
      splashColor: const Color.fromRGBO(143, 148, 251, 0.1),
    );
  }

  //  خروج از حساب 

  void _performLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) {return LoginAndSignUp();},),);},
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userName');
      await prefs.remove('password');
      await prefs.remove('avatarUrl');
      
      final provider = UserProvider.of(context);
      if (provider != null) {
        provider.updateImages([]);
        provider.updateAlbums([]);
        provider.updateUserName('');
        provider.updateAvatarUrl('');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginAndSignUp()),
        (route) => false,
      );
    }
  }
  //  ویرایش پروفایل 
  void _showEditProfileDialog(BuildContext context) {
    final userProvider = UserProvider.of(context);
    if (userProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User provider not found')),
      );
      return;
    }
    final nameController = TextEditingController(text: userProvider.userName);
    final avatarController = TextEditingController(text: userProvider.avatarUrl);
    String tempAvatarUrl = userProvider.avatarUrl;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // نمایش آواتار با پیش‌نمایش زنده
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromRGBO(143, 148, 251, 1),
                              width: 3,
                            ),
                            image: tempAvatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(tempAvatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.grey[200],
                          ),
                          child: tempAvatarUrl.isEmpty
                              ? Center(
                                  child: Text(
                                    nameController.text.isNotEmpty 
                                        ? nameController.text[0].toUpperCase() 
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        // دکمه دوربین برای تغییر عکس
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(143, 148, 251, 1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // فیلد ویرایش نام کاربری
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  // فیلد ویرایش آدرس آواتار
                  TextField(
                    controller: avatarController,
                    decoration: InputDecoration(
                      labelText: 'Avatar URL (Image URL)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                      suffixIcon: avatarController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                avatarController.clear();
                                setState(() {
                                  tempAvatarUrl = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        tempAvatarUrl = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // پیام تایید پیش‌نمایش آواتار
                  if (tempAvatarUrl.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Avatar preview is shown above',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newAvatar = avatarController.text.trim();
                  
                  if (newName.isNotEmpty) {
                    userProvider.updateUserName(newName);
                    userProvider.updateAvatarUrl(newAvatar);
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', newName);
                    if (newAvatar.isNotEmpty) {
                      await prefs.setString('avatarUrl', newAvatar);
                    } else {
                      await prefs.remove('avatarUrl');
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username cannot be empty'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  //  حساب کاربری
  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This action is irreversible! All your data will be permanently deleted.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // فیلد نام کاربری برای تایید
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                // فیلد رمز عبور برای تایید
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final enteredUsername = usernameController.text.trim();
                  final enteredPassword = passwordController.text.trim();

                  if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final prefs = await SharedPreferences.getInstance();
                  final savedUsername = prefs.getString('userName') ?? '';
                  final savedPassword = prefs.getString('password') ?? '';

                  if (enteredUsername == savedUsername && enteredPassword == savedPassword) {
                    await prefs.remove('isLoggedIn');
                    await prefs.remove('userName');
                    await prefs.remove('password');
                    await prefs.remove('avatarUrl');
                    
                    final provider = UserProvider.of(context);
                    if (provider != null) {
                      provider.updateImages([]);
                      provider.updateAlbums([]);
                      provider.updateUserName('');
                      provider.updateAvatarUrl('');
                    }

                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: Colors.red,
                      ),
                    );

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginAndSignUp()),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid username or password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  //  تغییر رمز عبور 
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}