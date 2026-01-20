import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 1)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final int userId;
  
  @HiveField(2)
  final int projectId;
  
  @HiveField(3)
  final String date;
  
  @HiveField(4)
  final String? checkIn;
  
  @HiveField(5)
  final String? checkOut;
  
  @HiveField(6)
  final double latitude;
  
  @HiveField(7)
  final double longitude;
  
  @HiveField(8)
  final bool isVerified;
  
  @HiveField(9)
  final bool isSynced;
  
  @HiveField(10)
  final String? localId;
  
  AttendanceModel({
    this.id,
    required this.userId,
    required this.projectId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.latitude,
    required this.longitude,
    this.isVerified = false,
    this.isSynced = false,
    this.localId,
  });
  
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['user_id'],
      projectId: json['project_id'],
      date: json['date'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] ?? false,
      isSynced: true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'project_id': projectId,
      'date': date,
      if (checkIn != null) 'check_in': checkIn,
      if (checkOut != null) 'check_out': checkOut,
      'latitude': latitude,
      'longitude': longitude,
      'is_verified': isVerified,
    };
  }
}
