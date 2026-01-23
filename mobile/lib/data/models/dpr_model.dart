import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';

part 'dpr_model.g.dart';

@HiveType(typeId: 3)
class DprModel extends HiveObject {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final int projectId;
  
  @HiveField(2)
  final int userId;
  
  @HiveField(3)
  final String workDescription;
  
  @HiveField(4)
  final String reportDate;
  
  @HiveField(5)
  final double latitude;
  
  @HiveField(6)
  final double longitude;
  
  @HiveField(7)
  final String status;
  
  @HiveField(8)
  final List<String> photoUrls;
  
  @HiveField(9)
  final List<String> localPhotoPaths;
  
  @HiveField(10)
  final bool isSynced;
  
  @HiveField(11)
  final String? localId;
  
  @HiveField(12)
  final String? projectName;
  
  DprModel({
    this.id,
    required this.projectId,
    required this.userId,
    required this.workDescription,
    required this.reportDate,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.photoUrls = const [],
    this.localPhotoPaths = const [],
    this.isSynced = false,
    this.localId,
    this.projectName,
  });
  
  factory DprModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List<dynamic>?;
    final photoUrls = photos?.map((p) {
      // Use full_url if available (complete API endpoint URL)
      final fullUrl = p['full_url'] as String?;
      if (fullUrl != null && fullUrl.isNotEmpty) {
        return fullUrl; // Already a complete URL
      }
      
      // Fallback: construct URL from relative photo_url
      final photoUrl = p['photo_url'] as String?;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        if (photoUrl.startsWith('http')) {
          return photoUrl;
        }
        // Construct full URL: base_url + /storage/ + photo_url
        final baseUrlWithoutApi = ApiConstants.baseUrl.replaceFirst('/api', '');
        return '$baseUrlWithoutApi/storage/$photoUrl';
      }
      
      return '';
    }).toList() ?? [];
    
    return DprModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      projectId: json['project_id'] is int ? json['project_id'] : int.parse(json['project_id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      workDescription: json['work_description'],
      reportDate: json['report_date'],
      latitude: json['latitude'] is double ? json['latitude'] : double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: json['longitude'] is double ? json['longitude'] : double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      status: json['status'],
      photoUrls: photoUrls,
      isSynced: true,
      projectName: json['project']?['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'user_id': userId,
      'work_description': workDescription,
      'report_date': reportDate,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }
}
