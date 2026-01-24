import 'package:hive/hive.dart';

part 'stock_transaction_model.g.dart';

@HiveType(typeId: 13)
class StockTransactionModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int projectId;
  
  @HiveField(2)
  final String transactionType; // 'IN' or 'OUT'
  
  @HiveField(3)
  final String source; // 'PO', 'MATERIAL_REQUEST', 'ADJUSTMENT'
  
  @HiveField(4)
  final int? sourceId; // PO ID or Material Request ID
  
  @HiveField(5)
  final String transactionDate;
  
  @HiveField(6)
  final List<StockItemModel> items;
  
  @HiveField(7)
  final String? projectName;
  
  @HiveField(8)
  final String? vendorName; // For Stock IN from PO
  
  @HiveField(9)
  final String? poNumber; // For Stock IN from PO
  
  @HiveField(10)
  final String? notes;
  
  @HiveField(11)
  final bool isSynced;
  
  @HiveField(12)
  final String? syncError;
  
  @HiveField(13)
  final String createdAt;
  
  @HiveField(14)
  final String updatedAt;
  
  @HiveField(15)
  final int? createdBy;
  
  @HiveField(16)
  final String? createdByName;

  StockTransactionModel({
    required this.id,
    required this.projectId,
    required this.transactionType,
    required this.source,
    this.sourceId,
    required this.transactionDate,
    required this.items,
    this.projectName,
    this.vendorName,
    this.poNumber,
    this.notes,
    this.isSynced = false,
    this.syncError,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.createdByName,
  });

  // Helper methods
  bool get isStockIn => transactionType == 'IN';
  bool get isStockOut => transactionType == 'OUT';
  bool get isPendingSync => !isSynced;
  
  double get totalQuantity {
    return items.fold(0.0, (sum, item) => sum + item.quantity);
  }

  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    return StockTransactionModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      transactionType: json['transaction_type'] as String,
      source: json['source'] as String,
      sourceId: json['source_id'] as int?,
      transactionDate: json['transaction_date'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => StockItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      projectName: json['project_name'] as String?,
      vendorName: json['vendor_name'] as String?,
      poNumber: json['po_number'] as String?,
      notes: json['notes'] as String?,
      isSynced: json['is_synced'] as bool? ?? true,
      syncError: json['sync_error'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      createdBy: json['created_by'] as int?,
      createdByName: json['created_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'transaction_type': transactionType,
      'source': source,
      'source_id': sourceId,
      'transaction_date': transactionDate,
      'items': items.map((item) => item.toJson()).toList(),
      'project_name': projectName,
      'vendor_name': vendorName,
      'po_number': poNumber,
      'notes': notes,
      'is_synced': isSynced,
      'sync_error': syncError,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'created_by_name': createdByName,
    };
  }

  StockTransactionModel copyWith({
    int? id,
    int? projectId,
    String? transactionType,
    String? source,
    int? sourceId,
    String? transactionDate,
    List<StockItemModel>? items,
    String? projectName,
    String? vendorName,
    String? poNumber,
    String? notes,
    bool? isSynced,
    String? syncError,
    String? createdAt,
    String? updatedAt,
    int? createdBy,
    String? createdByName,
  }) {
    return StockTransactionModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      transactionType: transactionType ?? this.transactionType,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      transactionDate: transactionDate ?? this.transactionDate,
      items: items ?? this.items,
      projectName: projectName ?? this.projectName,
      vendorName: vendorName ?? this.vendorName,
      poNumber: poNumber ?? this.poNumber,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}

@HiveType(typeId: 14)
class StockItemModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int materialId;
  
  @HiveField(2)
  final String materialName;
  
  @HiveField(3)
  final double quantity;
  
  @HiveField(4)
  final String unit;
  
  @HiveField(5)
  final String gstType; // 'GST' or 'NON_GST'
  
  @HiveField(6)
  final double? unitPrice;
  
  @HiveField(7)
  final double? totalAmount;
  
  @HiveField(8)
  final String? batchNumber;
  
  @HiveField(9)
  final String? expiryDate;
  
  @HiveField(10)
  final String? remarks;

  StockItemModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.gstType,
    this.unitPrice,
    this.totalAmount,
    this.batchNumber,
    this.expiryDate,
    this.remarks,
  });

  // Helper methods
  bool get isGST => gstType == 'GST';
  bool get isNonGST => gstType == 'NON_GST';
  
  double get calculatedTotal {
    if (unitPrice != null) {
      return quantity * unitPrice!;
    }
    return totalAmount ?? 0.0;
  }

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'] as int,
      materialId: json['material_id'] as int,
      materialName: json['material_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      gstType: json['gst_type'] as String,
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      batchNumber: json['batch_number'] as String?,
      expiryDate: json['expiry_date'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'material_name': materialName,
      'quantity': quantity,
      'unit': unit,
      'gst_type': gstType,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'batch_number': batchNumber,
      'expiry_date': expiryDate,
      'remarks': remarks,
    };
  }

  StockItemModel copyWith({
    int? id,
    int? materialId,
    String? materialName,
    double? quantity,
    String? unit,
    String? gstType,
    double? unitPrice,
    double? totalAmount,
    String? batchNumber,
    String? expiryDate,
    String? remarks,
  }) {
    return StockItemModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      gstType: gstType ?? this.gstType,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      remarks: remarks ?? this.remarks,
    );
  }
}
