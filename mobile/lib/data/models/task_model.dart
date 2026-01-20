import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
class TaskModel extends HiveObject {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final int projectId;
  
  @HiveField(2)
  final int assignedTo;
  
  @HiveField(3)
  final int assignedBy;
  
  @HiveField(4)
  final String title;
  
  @HiveField(5)
  final String description;
  
  @HiveField(6)
  final String status;
  
  @HiveField(7)
  final bool isSynced;
  
  @HiveField(8)
  final String? localId;
  
  @HiveField(9)
  final String? projectName;
  
  @HiveField(10)
  final String? assignedByName;
  
  TaskModel({
    this.id,
    required this.projectId,
    required this.assignedTo,
    required this.assignedBy,
    required this.title,
    required this.description,
    required this.status,
    this.isSynced = false,
    this.localId,
    this.projectName,
    this.assignedByName,
  });
  
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      projectId: json['project_id'],
      assignedTo: json['assigned_to'],
      assignedBy: json['assigned_by'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      isSynced: true,
      projectName: json['project']?['name'],
      assignedByName: json['assigned_by_user']?['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'assigned_to': assignedTo,
      'assigned_by': assignedBy,
      'title': title,
      'description': description,
      'status': status,
    };
  }
  
  TaskModel copyWith({
    int? id,
    int? projectId,
    int? assignedTo,
    int? assignedBy,
    String? title,
    String? description,
    String? status,
    bool? isSynced,
    String? localId,
    String? projectName,
    String? assignedByName,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      projectName: projectName ?? this.projectName,
      assignedByName: assignedByName ?? this.assignedByName,
    );
  }
}
