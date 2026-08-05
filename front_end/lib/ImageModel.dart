class ImageModel {
  final String name;
  final String imageUrl;
  int likes;
  List<String> likedByUsers;
  List<String> tags;
  List<String> comments;
  String? album;

  ImageModel({
    required this.name,
    required this.imageUrl,
    this.likes = 0,
    List<String>? likedByUsers,
    List<String>? tags,
    List<String>? comments,
    this.album,
  })  : likedByUsers = likedByUsers ?? [],
        tags = tags ?? [],
        comments = comments ?? [];
}