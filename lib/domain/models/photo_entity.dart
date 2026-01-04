import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoEntity {
  final String id;
  final String description;
  final String authorName;
  final String thumbnailUrl;
  final List<String> hashtags;
  final DateTime uploadDate;

  PhotoEntity({
    required this.id,
    required this.description,
    required this.authorName,
    required this.thumbnailUrl,
    required this.hashtags,
    required this.uploadDate,
  });

  factory PhotoEntity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PhotoEntity(
      id: doc.id,
      description: data['description'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
    );
  }
}