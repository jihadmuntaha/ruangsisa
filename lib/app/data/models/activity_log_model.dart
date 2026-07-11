// import 'dart:convert';

class ActivityLogModel {
  final int id;
  final int userId;
  final String action;
  final Map<String, dynamic> details;
  final String createdAt;

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      // 🟢 DEFENSIVE PARSING: Menggunakan 'or' dan casting aman agar kebal crash tipe data
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,

      // Mengakomodasi kunci 'action' atau 'activity' dari backend dengan aman
      action: json['action'] ?? json['activity'] ?? 'UNKNOWN_ACTION',

      // Memastikan properti 'details' atau 'description' diparsing sebagai Map valid
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'])
          : {'info': json['details']?.toString() ?? ''},

      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'details': details,
      'created_at': createdAt,
    };
  }
}
