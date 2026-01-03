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

  // --- ADD THIS FACTORY TO CLEAR THE RED LINE ---
  factory PhotoEntity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PhotoEntity(
      id: doc.id,
      // Default to empty strings if the field is missing to avoid crashes
      description: data['description'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      // Ensure hashtags is a list of strings
      hashtags: List<String>.from(data['hashtags'] ?? []),
      // Convert Firebase Timestamp to Dart DateTime
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
    );
  }
}