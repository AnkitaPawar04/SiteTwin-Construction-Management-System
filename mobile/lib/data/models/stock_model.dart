class StockModel {
  final int id;
  final int projectId;
  final int materialId;
  final double availableQuantity;
  final String? materialName;
  final String? materialUnit;
  final String? projectName;
  final String createdAt;
  final String updatedAt;

  StockModel({
    required this.id,
    required this.projectId,
    required this.materialId,
    required this.availableQuantity,
    this.materialName,
    this.materialUnit,
    this.projectName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    final material = json['material'] as Map<String, dynamic>?;
    final project = json['project'] as Map<String, dynamic>?;
    
    return StockModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      materialId: json['material_id'] as int,
      availableQuantity: (json['available_quantity'] is String)
          ? double.tryParse(json['available_quantity']) ?? 0.0
          : (json['available_quantity'] as num?)?.toDouble() ?? 0.0,
      materialName: material?['name'] as String?,
      materialUnit: material?['unit'] as String?,
      projectName: project?['name'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'material_id': materialId,
      'available_quantity': availableQuantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
