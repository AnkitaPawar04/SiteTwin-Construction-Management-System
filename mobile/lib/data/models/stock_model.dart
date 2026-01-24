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
    if (json.containsKey('material_name') && json.containsKey('total_stock')) {
      return StockModel(
        id: _parseIntValue(json['material_id']),
        projectId: 0, // Not available in this format
        materialId: _parseIntValue(json['material_id']),
        availableQuantity: _parseDoubleValue(json['total_stock']),
        materialName: json['material_name'] as String?,
        materialUnit: json['unit'] as String?,
        projectName: null,
        gstType: json['gst_type'] as String?,
        gstPercentage: _parseDoubleValue(json['gst_percentage']),
        totalStock: _parseDoubleValue(json['total_stock']),
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
      id: _parseIntValue(json['id']),
      projectId: _parseIntValue(json['project_id']),
      materialId: _parseIntValue(json['material_id']),
      availableQuantity: _parseDoubleValue(json['available_quantity']),
      materialName: material?['name'] as String?,
      materialUnit: material?['unit'] as String?,
      projectName: project?['name'] as String?,
      gstType: material?['gst_type'] as String?,
      gstPercentage: _parseDoubleValue(material?['gst_percentage']),
      totalStock: null,
      projectWiseStock: null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      projectId: StockModel._parseIntValue(json['project_id']),
      projectName: json['project_name'] as String? ?? '',
      stock: StockModel._parseDoubleValue(json['stock']),
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
