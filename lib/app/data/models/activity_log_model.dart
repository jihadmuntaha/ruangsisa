import 'dart:convert';

class ActivityLogModel {
  final int? id;
  final int? userId;
  final String action;
  final Map<String, dynamic> details;
  final String createdAt;

  ActivityLogModel({
    this.id,
    this.userId,
    required this.action,
    required this.details,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    // Parsing kolom details yang berbentuk string JSON di SQLite backend lu
    Map<String, dynamic> parsedDetails = {};
    if (json['details'] != null) {
      try {
        parsedDetails = json['details'] is String
            ? jsonDecode(json['details'])
            : json['details'];
      } catch (e) {
        parsedDetails = {"info": json['details'].toString()};
      }
    }

    return ActivityLogModel(
      id: json['id'],
      userId: json['user_id'],
      action: json['action'] ?? 'Aktivitas Tidak Diketahui',
      details: parsedDetails,
      createdAt: json['created_at'] ?? '',
    );
  }
}
