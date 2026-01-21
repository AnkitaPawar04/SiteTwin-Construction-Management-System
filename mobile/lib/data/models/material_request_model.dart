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
  });

  factory MaterialRequestModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      projectId: json['project_id'] is int ? json['project_id'] : int.parse(json['project_id'].toString()),
      requestedBy: json['requested_by'] is int ? json['requested_by'] : int.parse(json['requested_by'].toString()),
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      materialRequestId: json['material_request_id'] is int ? json['material_request_id'] : int.parse(json['material_request_id'].toString()),
      materialId: json['material_id'] is int ? json['material_id'] : int.parse(json['material_id'].toString()),
      quantity: json['quantity'] is double ? json['quantity'] : double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String,
      unit: json['unit'] as String,
      unitPrice: json['unit_price'] is double ? json['unit_price'] : double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      gstRate: json['gst_rate'] is double ? json['gst_rate'] : double.tryParse(json['gst_rate']?.toString() ?? '0') ?? 0.0,
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
