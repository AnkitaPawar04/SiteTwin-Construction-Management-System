import 'package:hive/hive.dart';

part 'material_request_model.g.dart';

@HiveType(typeId: 6)
class MaterialRequestModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int projectId;
  
  @HiveField(2)
  final int requestedBy;
  
  @HiveField(3)
  final String status;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final String? approvedBy;
  
  @HiveField(6)
  final String? approvedAt;
  
  @HiveField(7)
  final String createdAt;
  
  @HiveField(8)
  final String updatedAt;
  
  @HiveField(9)
  final String? projectName;
  
  @HiveField(10)
  final String? requestedByName;
  
  @HiveField(11)
  final List<MaterialRequestItemModel> items;
  
  @HiveField(12)
  final bool isSynced;
  
  @HiveField(13)
  final String? localId; // UUID for offline records
  
  // Alias for createdAt for convenience
  String get requestDate => createdAt;

  MaterialRequestModel({
    required this.id,
    required this.projectId,
    required this.requestedBy,
    required this.status,
    this.description,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.projectName,
    this.requestedByName,
    this.items = const [],
    this.isSynced = true,
    this.localId,
  });

  factory MaterialRequestModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestModel(
      id: _parseId(json['id']),
      projectId: _parseId(json['project_id']),
      requestedBy: _parseId(json['requested_by']),
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString(),
      approvedBy: json['approved_by']?.toString(),
      approvedAt: json['approved_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      projectName: json['project_name']?.toString(),
      requestedByName: json['requested_by_name']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MaterialRequestItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      isSynced: json['is_synced'] as bool? ?? true,
      localId: json['local_id']?.toString(),
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value == null) return 0;
    final parsed = int.tryParse(value.toString());
    return parsed ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'requested_by': requestedBy,
      'status': status,
      'description': description,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'project_name': projectName,
      'requested_by_name': requestedByName,
      'items': items.map((item) => item.toJson()).toList(),
      'is_synced': isSynced,
      'local_id': localId,
    };
  }

  MaterialRequestModel copyWith({
    int? id,
    int? projectId,
    int? requestedBy,
    String? status,
    String? description,
    String? approvedBy,
    String? approvedAt,
    String? createdAt,
    String? updatedAt,
    String? projectName,
    String? requestedByName,
    List<MaterialRequestItemModel>? items,
    bool? isSynced,
    String? localId,
  }) {
    return MaterialRequestModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      requestedBy: requestedBy ?? this.requestedBy,
      status: status ?? this.status,
      description: description ?? this.description,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectName: projectName ?? this.projectName,
      requestedByName: requestedByName ?? this.requestedByName,
      items: items ?? this.items,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
    );
  }
}

@HiveType(typeId: 7)
class MaterialRequestItemModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int materialRequestId;
  
  @HiveField(2)
  final int materialId;
  
  @HiveField(3)
  final int quantity;
  
  @HiveField(4)
  final String? materialName;
  
  @HiveField(5)
  final String? unit;

  MaterialRequestItemModel({
    required this.id,
    required this.materialRequestId,
    required this.materialId,
    required this.quantity,
    this.materialName,
    this.unit,
  });

  factory MaterialRequestItemModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestItemModel(
      id: _parseId(json['id']),
      materialRequestId: _parseId(json['material_request_id']),
      materialId: _parseId(json['material_id']),
      quantity: _parseQuantity(json['quantity']),
      materialName: json['material_name']?.toString(),
      unit: json['unit']?.toString(),
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value == null) return 0;
    final parsed = int.tryParse(value.toString());
    return parsed ?? 0;
  }

  static int _parseQuantity(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value == null) return 0;
    final parsed = int.tryParse(value.toString());
    return parsed ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_request_id': materialRequestId,
      'material_id': materialId,
      'quantity': quantity,
      'material_name': materialName,
      'unit': unit,
    };
  }
}

class MaterialModel {
  final int id;
  final String name;
  final String unit;
  final double unitPrice;
  final double gstRate;
  final String description;

  MaterialModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.gstRate,
    required this.description,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Handle decimal strings like "10.00"
      final doubleVal = double.tryParse(value);
      return doubleVal?.toInt() ?? 0;
    }
    return 0;
  }

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      unitPrice: _parseDouble(json['unit_price']),
      gstRate: _parseDouble(json['gst_rate'] ?? json['gst_percentage']),
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'unit_price': unitPrice,
      'gst_rate': gstRate,
      'description': description,
    };
  }
}
