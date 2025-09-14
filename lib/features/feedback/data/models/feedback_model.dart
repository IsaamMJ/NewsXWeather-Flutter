import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackType { bug, enhancement, general }

extension FeedbackTypeX on FeedbackType {
  String get label {
    switch (this) {
      case FeedbackType.bug:
        return '🐛 Report Bug';
      case FeedbackType.enhancement:
        return '✨ Suggest Enhancement';
      case FeedbackType.general:
        return '💬 General Feedback';
    }
  }

  String get value {
    switch (this) {
      case FeedbackType.bug:
        return 'bug';
      case FeedbackType.enhancement:
        return 'enhancement';
      case FeedbackType.general:
        return 'general';
    }
  }

  static FeedbackType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bug':
        return FeedbackType.bug;
      case 'enhancement':
        return FeedbackType.enhancement;
      case 'general':
      default:
        return FeedbackType.general;
    }
  }
}

enum FeedbackPriority { low, medium, high }

extension FeedbackPriorityX on FeedbackPriority {
  String get label {
    switch (this) {
      case FeedbackPriority.low:
        return 'Low';
      case FeedbackPriority.medium:
        return 'Medium';
      case FeedbackPriority.high:
        return 'High';
    }
  }

  String get value {
    switch (this) {
      case FeedbackPriority.low:
        return 'low';
      case FeedbackPriority.medium:
        return 'medium';
      case FeedbackPriority.high:
        return 'high';
    }
  }

  static FeedbackPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return FeedbackPriority.low;
      case 'medium':
        return FeedbackPriority.medium;
      case 'high':
        return FeedbackPriority.high;
      default:
        return FeedbackPriority.medium;
    }
  }
}

class FeedbackModel {
  final String? id;
  final String userId;
  final String? userEmail;
  final String displayName;
  final FeedbackType type;
  final String title;
  final String description;
  final FeedbackPriority priority;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> appInfo;
  final Map<String, dynamic> userSettings;
  final DateTime timestamp;
  final String status;

  FeedbackModel({
    this.id,
    required this.userId,
    this.userEmail,
    required this.displayName,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.deviceInfo,
    required this.appInfo,
    required this.userSettings,
    required this.timestamp,
    this.status = 'submitted',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'displayName': displayName,
      'feedbackType': type.value,
      'title': title,
      'description': description,
      'priority': priority.value,
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
      'userSettings': userSettings,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'],
      displayName: map['displayName'] ?? '',
      type: FeedbackTypeX.fromString(map['feedbackType'] ?? 'general'),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: FeedbackPriorityX.fromString(map['priority'] ?? 'medium'),
      deviceInfo: Map<String, dynamic>.from(map['deviceInfo'] ?? {}),
      appInfo: Map<String, dynamic>.from(map['appInfo'] ?? {}),
      userSettings: Map<String, dynamic>.from(map['userSettings'] ?? {}),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'submitted',
    );
  }
}