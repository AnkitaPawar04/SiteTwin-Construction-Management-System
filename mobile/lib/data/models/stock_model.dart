class StockModel {
  final int id;
  final int projectId;
  final int materialId;
  final double availableQuantity;
  final String? materialName;
  final String? materialUnit;
  final String? projectName;
  final String? gstType;
  final double? gstPercentage;
  final double? totalStock;
  final List<ProjectStockModel>? projectWiseStock;
  final String? createdAt;
  final String? updatedAt;

  StockModel({
    required this.id,
    required this.projectId,
    required this.materialId,
    required this.availableQuantity,
    this.materialName,
    this.materialUnit,
    this.projectName,
    this.gstType,
    this.gstPercentage,
    this.totalStock,
    this.projectWiseStock,
    this.createdAt,
    this.updatedAt,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    // Check if this is from the new getAllStock API (Phase 3 format)
    if (json.containsKey('material_name') && json.containsKey('current_stock')) {
      return StockModel(
        id: (json['material_id'] as num?)?.toInt() ?? 0,
        projectId: 0, // Not available in this format
        materialId: (json['material_id'] as num?)?.toInt() ?? 0,
        availableQuantity: (json['current_stock'] is String)
            ? double.tryParse(json['current_stock']) ?? 0.0
            : (json['current_stock'] as num?)?.toDouble() ?? 0.0,
        materialName: json['material_name'] as String?,
        materialUnit: json['unit'] as String?,
        projectName: null,
        gstType: json['gst_type'] as String?,
        gstPercentage: (json['gst_percentage'] as num?)?.toDouble(),
        totalStock: (json['total_stock'] is String)
            ? double.tryParse(json['total_stock']) ?? 0.0
            : (json['total_stock'] as num?)?.toDouble(),
        projectWiseStock: (json['project_wise_stock'] as List<dynamic>?)
            ?.map((item) => ProjectStockModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
    }
    
    // Old format (from specific project stock endpoints)
    final material = json['material'] as Map<String, dynamic>?;
    final project = json['project'] as Map<String, dynamic>?;
    
    return StockModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      projectId: (json['project_id'] as num?)?.toInt() ?? 0,
      materialId: (json['material_id'] as num?)?.toInt() ?? 0,
      availableQuantity: (json['available_quantity'] is String)
          ? double.tryParse(json['available_quantity']) ?? 0.0
          : (json['available_quantity'] as num?)?.toDouble() ?? 0.0,
      materialName: material?['name'] as String?,
      materialUnit: material?['unit'] as String?,
      projectName: project?['name'] as String?,
      gstType: material?['gst_type'] as String?,
      gstPercentage: (material?['gst_percentage'] as num?)?.toDouble(),
      totalStock: null,
      projectWiseStock: null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'material_id': materialId,
      'available_quantity': availableQuantity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

// Model for project-wise stock breakdown
class ProjectStockModel {
  final int projectId;
  final String projectName;
  final double stock;

  ProjectStockModel({
    required this.projectId,
    required this.projectName,
    required this.stock,
  });

  factory ProjectStockModel.fromJson(Map<String, dynamic> json) {
    return ProjectStockModel(
      projectId: (json['project_id'] as num?)?.toInt() ?? 0,
      projectName: json['project_name'] as String? ?? '',
      stock: (json['stock'] is String)
          ? double.tryParse(json['stock']) ?? 0.0
          : (json['stock'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'stock': stock,
    };
  }
}
