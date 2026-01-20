class MaterialRequestModel {
  final int id;
  final int projectId;
  final int requestedBy;
  final String status;
  final String? description;
  final String? approvedBy;
  final String? approvedAt;
  final String createdAt;
  final String updatedAt;
  final String? projectName;
  final String? requestedByName;
  final List<MaterialRequestItemModel> items;

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
  });

  factory MaterialRequestModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      requestedBy: json['requested_by'] as int,
      status: json['status'] as String,
      description: json['description'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      projectName: json['project_name'] as String?,
      requestedByName: json['requested_by_name'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MaterialRequestItemModel.fromJson(item))
              .toList()
          : [],
    );
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
    };
  }
}

class MaterialRequestItemModel {
  final int id;
  final int materialRequestId;
  final int materialId;
  final double quantity;
  final String? materialName;
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
      id: json['id'] as int,
      materialRequestId: json['material_request_id'] as int,
      materialId: json['material_id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      materialName: json['material_name'] as String?,
      unit: json['unit'] as String?,
    );
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

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      gstRate: (json['gst_rate'] as num).toDouble(),
      description: json['description'] as String? ?? '',
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
