class ProjectCostModel {
  final int projectId;
  final String projectName;
  final double totalCost;
  final double gstCost;
  final double nonGstCost;
  final double totalGstAmount;
  final int totalPOs;
  final int totalInvoices;
  final double budgetAmount;
  final double spentPercentage;
  final List<CostBreakdownModel> costBreakdown;
  final String updatedAt;

  ProjectCostModel({
    required this.projectId,
    required this.projectName,
    required this.totalCost,
    required this.gstCost,
    required this.nonGstCost,
    required this.totalGstAmount,
    required this.totalPOs,
    required this.totalInvoices,
    required this.budgetAmount,
    required this.spentPercentage,
    required this.costBreakdown,
    required this.updatedAt,
  });

  // Helper getters
  double get budgetRemaining => budgetAmount - totalCost;
  bool get isOverBudget => totalCost > budgetAmount;
  double get gstPercentage => totalCost > 0 ? (gstCost / totalCost) * 100 : 0;
  double get nonGstPercentage => totalCost > 0 ? (nonGstCost / totalCost) * 100 : 0;

  factory ProjectCostModel.fromJson(Map<String, dynamic> json) {
    return ProjectCostModel(
      projectId: json['project_id'] as int,
      projectName: json['project_name'] as String,
      totalCost: (json['total_cost'] as num).toDouble(),
      gstCost: (json['gst_cost'] as num).toDouble(),
      nonGstCost: (json['non_gst_cost'] as num).toDouble(),
      totalGstAmount: (json['total_gst_amount'] as num).toDouble(),
      totalPOs: json['total_pos'] as int,
      totalInvoices: json['total_invoices'] as int,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble() ?? 0,
      spentPercentage: (json['spent_percentage'] as num?)?.toDouble() ?? 0,
      costBreakdown: (json['cost_breakdown'] as List<dynamic>?)
          ?.map((item) => CostBreakdownModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'total_cost': totalCost,
      'gst_cost': gstCost,
      'non_gst_cost': nonGstCost,
      'total_gst_amount': totalGstAmount,
      'total_pos': totalPOs,
      'total_invoices': totalInvoices,
      'budget_amount': budgetAmount,
      'spent_percentage': spentPercentage,
      'cost_breakdown': costBreakdown.map((item) => item.toJson()).toList(),
      'updated_at': updatedAt,
    };
  }
}

class CostBreakdownModel {
  final String category;
  final double amount;
  final double percentage;
  final int itemCount;

  CostBreakdownModel({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.itemCount,
  });

  factory CostBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CostBreakdownModel(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      itemCount: json['item_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'percentage': percentage,
      'item_count': itemCount,
    };
  }
}

class ConsumptionVarianceModel {
  final int projectId;
  final String projectName;
  final int materialId;
  final String materialName;
  final String unit;
  final double theoreticalQuantity;
  final double actualQuantity;
  final double varianceQuantity;
  final double variancePercentage;
  final String varianceType; // 'WASTAGE', 'SAVINGS', 'NORMAL'
  final double theoreticalCost;
  final double actualCost;
  final double costVariance;
  final String updatedAt;

  ConsumptionVarianceModel({
    required this.projectId,
    required this.projectName,
    required this.materialId,
    required this.materialName,
    required this.unit,
    required this.theoreticalQuantity,
    required this.actualQuantity,
    required this.varianceQuantity,
    required this.variancePercentage,
    required this.varianceType,
    required this.theoreticalCost,
    required this.actualCost,
    required this.costVariance,
    required this.updatedAt,
  });

  // Helper getters
  bool get isWastage => varianceType == 'WASTAGE';
  bool get isSavings => varianceType == 'SAVINGS';
  bool get isHighVariance => variancePercentage.abs() > 10; // More than 10%

  factory ConsumptionVarianceModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionVarianceModel(
      projectId: json['project_id'] as int,
      projectName: json['project_name'] as String,
      materialId: json['material_id'] as int,
      materialName: json['material_name'] as String,
      unit: json['unit'] as String,
      theoreticalQuantity: (json['theoretical_quantity'] as num).toDouble(),
      actualQuantity: (json['actual_quantity'] as num).toDouble(),
      varianceQuantity: (json['variance_quantity'] as num).toDouble(),
      variancePercentage: (json['variance_percentage'] as num).toDouble(),
      varianceType: json['variance_type'] as String,
      theoreticalCost: (json['theoretical_cost'] as num).toDouble(),
      actualCost: (json['actual_cost'] as num).toDouble(),
      costVariance: (json['cost_variance'] as num).toDouble(),
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'material_id': materialId,
      'material_name': materialName,
      'unit': unit,
      'theoretical_quantity': theoreticalQuantity,
      'actual_quantity': actualQuantity,
      'variance_quantity': varianceQuantity,
      'variance_percentage': variancePercentage,
      'variance_type': varianceType,
      'theoretical_cost': theoreticalCost,
      'actual_cost': actualCost,
      'cost_variance': costVariance,
      'updated_at': updatedAt,
    };
  }
}

class UnitCostModel {
  final int projectId;
  final String projectName;
  final int unitId;
  final String unitNumber;
  final String unitType; // 'FLAT', 'SHOP', 'OFFICE'
  final String saleStatus; // 'SOLD', 'UNSOLD', 'BLOCKED'
  final double totalCost;
  final double materialCost;
  final double laborCost;
  final double overheadCost;
  final double area; // Square feet or square meters
  final double costPerSqft;
  final double salePrice;
  final double profitMargin;
  final String updatedAt;

  UnitCostModel({
    required this.projectId,
    required this.projectName,
    required this.unitId,
    required this.unitNumber,
    required this.unitType,
    required this.saleStatus,
    required this.totalCost,
    required this.materialCost,
    required this.laborCost,
    required this.overheadCost,
    required this.area,
    required this.costPerSqft,
    required this.salePrice,
    required this.profitMargin,
    required this.updatedAt,
  });

  // Helper getters
  bool get isSold => saleStatus == 'SOLD';
  bool get isUnsold => saleStatus == 'UNSOLD';
  bool get isProfitable => profitMargin > 0;
  double get profitAmount => salePrice - totalCost;

  factory UnitCostModel.fromJson(Map<String, dynamic> json) {
    return UnitCostModel(
      projectId: json['project_id'] as int,
      projectName: json['project_name'] as String,
      unitId: json['unit_id'] as int,
      unitNumber: json['unit_number'] as String,
      unitType: json['unit_type'] as String,
      saleStatus: json['sale_status'] as String,
      totalCost: (json['total_cost'] as num).toDouble(),
      materialCost: (json['material_cost'] as num).toDouble(),
      laborCost: (json['labor_cost'] as num).toDouble(),
      overheadCost: (json['overhead_cost'] as num).toDouble(),
      area: (json['area'] as num).toDouble(),
      costPerSqft: (json['cost_per_sqft'] as num).toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profit_margin'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'unit_id': unitId,
      'unit_number': unitNumber,
      'unit_type': unitType,
      'sale_status': saleStatus,
      'total_cost': totalCost,
      'material_cost': materialCost,
      'labor_cost': laborCost,
      'overhead_cost': overheadCost,
      'area': area,
      'cost_per_sqft': costPerSqft,
      'sale_price': salePrice,
      'profit_margin': profitMargin,
      'updated_at': updatedAt,
    };
  }
}
