import 'package:hive/hive.dart';

part 'sync_queue_model.g.dart';

@HiveType(typeId: 5)
class SyncQueueModel {
  @HiveField(0)
  final String id; // UUID
  
  @HiveField(1)
  final String entityType; // 'attendance', 'dpr', 'task', 'material_request'
  
  @HiveField(2)
  final String entityId; // Local UUID or server ID
  
  @HiveField(3)
  final String action; // 'create', 'update'
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final int retryCount;
  
  @HiveField(6)
  final String? errorMessage;

  SyncQueueModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.timestamp,
    this.retryCount = 0,
    this.errorMessage,
  });

  SyncQueueModel copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? action,
    DateTime? timestamp,
    int? retryCount,
    String? errorMessage,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'retry_count': retryCount,
      'error_message': errorMessage,
    };
  }

  factory SyncQueueModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueModel(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
    );
  }
}
