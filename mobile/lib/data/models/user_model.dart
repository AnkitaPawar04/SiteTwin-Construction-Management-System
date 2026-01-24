import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String phone;
  
  @HiveField(3)
  final String role;
  
  @HiveField(4)
  final String language;
  
  @HiveField(5)
  final bool isActive;
  
  @HiveField(6)
  final String? email;
  
  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.language,
    required this.isActive,
    this.email,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      language: json['language'] ?? 'en',
      isActive: json['is_active'] ?? true,
      email: json['email'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'language': language,
      'is_active': isActive,
      'email': email,
    };
  }
  
  // Role helper methods (new backend roles)
  bool get isWorker => role == 'worker';
  bool get isSiteEngineer => role == 'site_engineer' || role == 'engineer'; // Legacy support
  bool get isPurchaseManager => role == 'purchase_manager';
  bool get isProjectManager => role == 'project_manager' || role == 'manager'; // Legacy support
  bool get isSafetyOfficer => role == 'safety_officer';
  bool get isOwner => role == 'owner';
  
  // Legacy support
  bool get isEngineer => isSiteEngineer;
  bool get isManager => isProjectManager;
}
