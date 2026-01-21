class StockTransactionModel {
  final int id;
  final int projectId;
  final int materialId;
  final double quantity;
  final String type; // 'in' or 'out'
  final int? referenceId;
  final String? materialName;
  final String? materialUnit;
  final String? projectName;
  final String createdAt;

  StockTransactionModel({
    required this.id,
    required this.projectId,
    required this.materialId,
    required this.quantity,
    required this.type,
    this.referenceId,
    this.materialName,
    this.materialUnit,
    this.projectName,
    required this.createdAt,
  });

  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    final material = json['material'] as Map<String, dynamic>?;
    final project = json['project'] as Map<String, dynamic>?;
    
    return StockTransactionModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      materialId: json['material_id'] as int,
      quantity: (json['quantity'] is String)
          ? double.tryParse(json['quantity']) ?? 0.0
          : (json['quantity'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String,
      referenceId: json['reference_id'] as int?,
      materialName: material?['name'] as String?,
      materialUnit: material?['unit'] as String?,
      projectName: project?['name'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'material_id': materialId,
      'quantity': quantity,
      'type': type,
      if (referenceId != null) 'reference_id': referenceId,
      'created_at': createdAt,
    };
  }
}
