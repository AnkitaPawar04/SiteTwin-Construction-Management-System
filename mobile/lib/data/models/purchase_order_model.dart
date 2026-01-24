import 'package:hive/hive.dart';

part 'purchase_order_model.g.dart';

@HiveType(typeId: 10)
class PurchaseOrderModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int? materialRequestId;
  
  @HiveField(2)
  final int vendorId;
  
  @HiveField(3)
  final String poNumber;
  
  @HiveField(4)
  final String poDate;
  
  @HiveField(5)
  final double totalAmount;
  
  @HiveField(6)
  final String gstType; // 'GST' or 'NON_GST'
  
  @HiveField(7)
  final String status; // 'CREATED', 'APPROVED', 'DELIVERED', 'CLOSED'
  
  @HiveField(8)
  final List<PurchaseOrderItemModel> items;
  
  @HiveField(9)
  final String? vendorName;
  
  @HiveField(10)
  final String? notes;
  
  @HiveField(11)
  final String? invoiceUrl;
  
  @HiveField(12)
  final String? deliveryDate;
  
  @HiveField(13)
  final String createdAt;
  
  @HiveField(14)
  final String updatedAt;
  
  @HiveField(15)
  final bool isSynced;
  
  @HiveField(16)
  final String? localId;

  PurchaseOrderModel({
    required this.id,
    this.materialRequestId,
    required this.vendorId,
    required this.poNumber,
    required this.poDate,
    required this.totalAmount,
    required this.gstType,
    required this.status,
    this.items = const [],
    this.vendorName,
    this.notes,
    this.invoiceUrl,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
    this.localId,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: _parseId(json['id']),
      materialRequestId: json['material_request_id'] != null 
          ? _parseId(json['material_request_id']) 
          : null,
      vendorId: _parseId(json['vendor_id']),
      poNumber: json['po_number']?.toString() ?? '',
      poDate: json['po_date']?.toString() ?? '',
      totalAmount: _parseDouble(json['total_amount']),
      gstType: json['gst_type']?.toString() ?? 'GST',
      status: json['status']?.toString() ?? 'CREATED',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => PurchaseOrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      vendorName: json['vendor_name']?.toString(),
      notes: json['notes']?.toString(),
      invoiceUrl: json['invoice_url']?.toString(),
      deliveryDate: json['delivery_date']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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

  static double _parseDouble(dynamic value) {
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
      'vendor_id': vendorId,
      'po_number': poNumber,
      'po_date': poDate,
      'total_amount': totalAmount,
      'gst_type': gstType,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'vendor_name': vendorName,
      'notes': notes,
      'invoice_url': invoiceUrl,
      'delivery_date': deliveryDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
      'local_id': localId,
    };
  }

  PurchaseOrderModel copyWith({
    int? id,
    int? materialRequestId,
    int? vendorId,
    String? poNumber,
    String? poDate,
    double? totalAmount,
    String? gstType,
    String? status,
    List<PurchaseOrderItemModel>? items,
    String? vendorName,
    String? notes,
    String? invoiceUrl,
    String? deliveryDate,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
    String? localId,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      materialRequestId: materialRequestId ?? this.materialRequestId,
      vendorId: vendorId ?? this.vendorId,
      poNumber: poNumber ?? this.poNumber,
      poDate: poDate ?? this.poDate,
      totalAmount: totalAmount ?? this.totalAmount,
      gstType: gstType ?? this.gstType,
      status: status ?? this.status,
      items: items ?? this.items,
      vendorName: vendorName ?? this.vendorName,
      notes: notes ?? this.notes,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
    );
  }

  bool get isGST => gstType.toUpperCase() == 'GST';
  bool get isNonGST => gstType.toUpperCase() == 'NON_GST';
}

@HiveType(typeId: 11)
class PurchaseOrderItemModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int purchaseOrderId;
  
  @HiveField(2)
  final int productId;
  
  @HiveField(3)
  final String productName;
  
  @HiveField(4)
  final int quantity;
  
  @HiveField(5)
  final double unitPrice;
  
  @HiveField(6)
  final double gstRate;
  
  @HiveField(7)
  final double totalPrice;
  
  @HiveField(8)
  final String? unit;

  PurchaseOrderItemModel({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.gstRate,
    required this.totalPrice,
    this.unit,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemModel(
      id: _parseId(json['id']),
      purchaseOrderId: _parseId(json['purchase_order_id']),
      productId: _parseId(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseDouble(json['unit_price']),
      gstRate: _parseDouble(json['gst_rate']),
      totalPrice: _parseDouble(json['total_price']),
      unit: json['unit']?.toString(),
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value == null) return 0;
    final parsed = int.tryParse(value.toString());
    return parsed ?? 0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value == null) return 0;
    final parsed = int.tryParse(value.toString());
    return parsed ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value == null) return 0.0;
    final parsed = double.tryParse(value.toString());
    return parsed ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_order_id': purchaseOrderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'gst_rate': gstRate,
      'total_price': totalPrice,
      'unit': unit,
    };
  }

  double get gstAmount => totalPrice * (gstRate / 100);
  double get amountWithGST => totalPrice + gstAmount;
}
