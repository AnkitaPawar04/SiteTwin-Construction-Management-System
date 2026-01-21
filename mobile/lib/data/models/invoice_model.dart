class InvoiceModel {
  final int id;
  final int projectId;
  final String invoiceNumber;
  final double totalAmount;
  final double gstAmount;
  final String status; // 'generated', 'paid'
  final String? projectName;
  final List<InvoiceItemModel> items;
  final String createdAt;

  InvoiceModel({
    required this.id,
    required this.projectId,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.gstAmount,
    required this.status,
    this.projectName,
    required this.items,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>?;
    final itemsList = json['items'] as List<dynamic>? ?? [];
    
    return InvoiceModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      totalAmount: (json['total_amount'] is String)
          ? double.tryParse(json['total_amount']) ?? 0.0
          : (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gst_amount'] is String)
          ? double.tryParse(json['gst_amount']) ?? 0.0
          : (json['gst_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      projectName: project?['name'] as String?,
      items: itemsList.map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>)).toList(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'gst_amount': gstAmount,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}

class InvoiceItemModel {
  final int id;
  final int invoiceId;
  final String description;
  final double amount;
  final double gstPercentage;

  InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.amount,
    required this.gstPercentage,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as int,
      invoiceId: json['invoice_id'] as int,
      description: json['description'] as String,
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      gstPercentage: (json['gst_percentage'] is String)
          ? double.tryParse(json['gst_percentage']) ?? 0.0
          : (json['gst_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'description': description,
      'amount': amount,
      'gst_percentage': gstPercentage,
    };
  }
}
