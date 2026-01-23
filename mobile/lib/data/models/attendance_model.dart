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
  final double markedLatitude;
  
  @HiveField(7)
  final double markedLongitude;
  
  @HiveField(8)
  final int? distanceFromGeofence;
  
  @HiveField(9)
  final bool isWithinGeofence;
  
  @HiveField(10)
  final bool isVerified;
  
  @HiveField(11)
  final bool isSynced;
  
  @HiveField(12)
  final String? localId;
  
  @HiveField(13)
  final String? userName;
  
  AttendanceModel({
    this.id,
    required this.userId,
    required this.projectId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.markedLatitude,
    required this.markedLongitude,
    this.distanceFromGeofence,
    this.isWithinGeofence = true,
    this.isVerified = false,
    this.isSynced = false,
    this.localId,
    this.userName,
  });
  
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      projectId: json['project_id'] is int ? json['project_id'] : int.parse(json['project_id'].toString()),
      date: json['date'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      markedLatitude: json['marked_latitude'] is double ? json['marked_latitude'] : double.tryParse(json['marked_latitude']?.toString() ?? '0') ?? 0.0,
      markedLongitude: json['marked_longitude'] is double ? json['marked_longitude'] : double.tryParse(json['marked_longitude']?.toString() ?? '0') ?? 0.0,
      distanceFromGeofence: json['distance_from_geofence'] is int ? json['distance_from_geofence'] : int.tryParse(json['distance_from_geofence']?.toString() ?? '0'),
      isWithinGeofence: json['is_within_geofence'] ?? true,
      isVerified: json['is_verified'] ?? false,
      isSynced: true,
      userName: json['user']?['name'] ?? json['user_name'],
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
      'marked_latitude': markedLatitude,
      'marked_longitude': markedLongitude,
      'is_verified': isVerified,
    };
  }
}
