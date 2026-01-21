class DashboardModel {
  final int projectsCount;
  final List<DashboardProject> projects;
  final FinancialOverview financialOverview;
  final AttendanceSummary attendanceSummary;
  final List<MaterialConsumption> materialConsumption;

  DashboardModel({
    required this.projectsCount,
    required this.projects,
    required this.financialOverview,
    required this.attendanceSummary,
    required this.materialConsumption,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      projectsCount: json['projects_count'] as int? ?? 0,
      projects: (json['projects'] as List<dynamic>?)
              ?.map((p) => DashboardProject.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      financialOverview: FinancialOverview.fromJson(
          json['financial_overview'] as Map<String, dynamic>? ?? {}),
      attendanceSummary: AttendanceSummary.fromJson(
          json['attendance_summary'] as Map<String, dynamic>? ?? {}),
      materialConsumption: (json['material_consumption'] as List<dynamic>?)
              ?.map((m) => MaterialConsumption.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DashboardProject {
  final int id;
  final String name;
  final String location;
  final String? startDate;
  final String? endDate;
  final double progress;

  DashboardProject({
    required this.id,
    required this.name,
    required this.location,
    this.startDate,
    this.endDate,
    required this.progress,
  });

  factory DashboardProject.fromJson(Map<String, dynamic> json) {
    return DashboardProject(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      progress: json['progress'] is String
          ? double.tryParse(json['progress']) ?? 0.0
          : (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FinancialOverview {
  final int totalInvoices;
  final double totalAmount;
  final double totalGst;
  final double paidAmount;
  final double pendingAmount;

  FinancialOverview({
    required this.totalInvoices,
    required this.totalAmount,
    required this.totalGst,
    required this.paidAmount,
    required this.pendingAmount,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) {
    return FinancialOverview(
      totalInvoices: json['total_invoices'] as int? ?? 0,
      totalAmount: json['total_amount'] is String
          ? double.tryParse(json['total_amount']) ?? 0.0
          : (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalGst: json['total_gst'] is String
          ? double.tryParse(json['total_gst']) ?? 0.0
          : (json['total_gst'] as num?)?.toDouble() ?? 0.0,
      paidAmount: json['paid_amount'] is String
          ? double.tryParse(json['paid_amount']) ?? 0.0
          : (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: json['pending_amount'] is String
          ? double.tryParse(json['pending_amount']) ?? 0.0
          : (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AttendanceSummary {
  final int todayAttendance;
  final int totalWorkers;

  AttendanceSummary({
    required this.todayAttendance,
    required this.totalWorkers,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      todayAttendance: json['today_attendance'] as int? ?? 0,
      totalWorkers: json['total_workers'] as int? ?? 0,
    );
  }
}

class MaterialConsumption {
  final String material;
  final String unit;
  final double availableQuantity;

  MaterialConsumption({
    required this.material,
    required this.unit,
    required this.availableQuantity,
  });

  factory MaterialConsumption.fromJson(Map<String, dynamic> json) {
    return MaterialConsumption(
      material: json['material'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      availableQuantity: json['available_quantity'] is String
          ? double.tryParse(json['available_quantity']) ?? 0.0
          : (json['available_quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
