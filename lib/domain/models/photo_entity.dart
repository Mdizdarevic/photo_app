class PhotoEntity {
  final String id;
  final String thumbnailUrl; // Match your UI's 'photo.thumbnailUrl'
  final DateTime uploadDate; // Match your UI's 'photo.uploadDateTime'
  final String authorName; // Match your UI's 'photo.authorName'
  final String description; // Match your UI's 'photo.description'
  final List<String> hashtags;

  PhotoEntity({
    required this.id,
    required this.thumbnailUrl,
    required this.uploadDate,
    required this.authorName,
    required this.description,
    required this.hashtags,
  });
}