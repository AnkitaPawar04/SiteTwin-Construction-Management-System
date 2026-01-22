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

  static double _parseQuantity(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value == null) return 0.0;
    final parsed = double.tryParse(value.toString());
    return parsed ?? 0.0;
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
