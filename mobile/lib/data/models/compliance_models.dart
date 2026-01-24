// Phase 6: Advanced Compliance & Field Features Models

class ContractorRatingModel {
  final int contractorId;
  final String contractorName;
  final String company;
  final String phone;
  final double rating; // 1.0 to 10.0
  final int totalProjects;
  final int completedProjects;
  final double onTimeDeliveryRate; // Percentage
  final double qualityScore; // 1.0 to 10.0
  final String paymentAdvice; // 'GOOD', 'CAUTION', 'DELAYED'
  final int totalPOs;
  final double totalValue;
  final String lastProjectDate;
  final List<ProjectPerformanceModel> recentProjects;
  final String updatedAt;

  ContractorRatingModel({
    required this.contractorId,
    required this.contractorName,
    required this.company,
    required this.phone,
    required this.rating,
    required this.totalProjects,
    required this.completedProjects,
    required this.onTimeDeliveryRate,
    required this.qualityScore,
    required this.paymentAdvice,
    required this.totalPOs,
    required this.totalValue,
    required this.lastProjectDate,
    required this.recentProjects,
    required this.updatedAt,
  });

  // Helper getters
  bool get isGoodRating => rating >= 7.0;
  bool get isAverageRating => rating >= 4.0 && rating < 7.0;
  bool get isPoorRating => rating < 4.0;
  bool get hasPaymentIssues => paymentAdvice == 'DELAYED' || paymentAdvice == 'CAUTION';

  factory ContractorRatingModel.fromJson(Map<String, dynamic> json) {
    return ContractorRatingModel(
      contractorId: json['contractor_id'] as int,
      contractorName: json['contractor_name'] as String,
      company: json['company'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalProjects: json['total_projects'] as int,
      completedProjects: json['completed_projects'] as int,
      onTimeDeliveryRate: (json['on_time_delivery_rate'] as num).toDouble(),
      qualityScore: (json['quality_score'] as num).toDouble(),
      paymentAdvice: json['payment_advice'] as String,
      totalPOs: json['total_pos'] as int,
      totalValue: (json['total_value'] as num).toDouble(),
      lastProjectDate: json['last_project_date'] as String,
      recentProjects: (json['recent_projects'] as List<dynamic>?)
          ?.map((item) => ProjectPerformanceModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractor_id': contractorId,
      'contractor_name': contractorName,
      'company': company,
      'phone': phone,
      'rating': rating,
      'total_projects': totalProjects,
      'completed_projects': completedProjects,
      'on_time_delivery_rate': onTimeDeliveryRate,
      'quality_score': qualityScore,
      'payment_advice': paymentAdvice,
      'total_pos': totalPOs,
      'total_value': totalValue,
      'last_project_date': lastProjectDate,
      'recent_projects': recentProjects.map((p) => p.toJson()).toList(),
      'updated_at': updatedAt,
    };
  }
}

class ProjectPerformanceModel {
  final int projectId;
  final String projectName;
  final double rating;
  final String status;
  final String completedDate;

  ProjectPerformanceModel({
    required this.projectId,
    required this.projectName,
    required this.rating,
    required this.status,
    required this.completedDate,
  });

  factory ProjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    return ProjectPerformanceModel(
      projectId: json['project_id'] as int,
      projectName: json['project_name'] as String,
      rating: (json['rating'] as num).toDouble(),
      status: json['status'] as String,
      completedDate: json['completed_date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'rating': rating,
      'status': status,
      'completed_date': completedDate,
    };
  }
}

class FaceRecallAttendanceModel {
  final int attendanceId;
  final int workerId;
  final String workerName;
  final String photoPath;
  final String checkInTime;
  final String? checkOutTime;
  final String status; // 'CHECKED_IN', 'CHECKED_OUT'
  final String locationType; // 'SITE', 'OFFICE'
  final double? latitude;
  final double? longitude;
  final double? faceMatchConfidence; // 0.0 to 1.0
  final String updatedAt;

  FaceRecallAttendanceModel({
    required this.attendanceId,
    required this.workerId,
    required this.workerName,
    required this.photoPath,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.locationType,
    this.latitude,
    this.longitude,
    this.faceMatchConfidence,
    required this.updatedAt,
  });

  bool get isCheckedIn => status == 'CHECKED_IN';
  bool get isCheckedOut => status == 'CHECKED_OUT';
  bool get hasHighConfidence => (faceMatchConfidence ?? 0.0) >= 0.8;

  factory FaceRecallAttendanceModel.fromJson(Map<String, dynamic> json) {
    return FaceRecallAttendanceModel(
      attendanceId: json['attendance_id'] as int,
      workerId: json['worker_id'] as int,
      workerName: json['worker_name'] as String,
      photoPath: json['photo_path'] as String,
      checkInTime: json['check_in_time'] as String,
      checkOutTime: json['check_out_time'] as String?,
      status: json['status'] as String,
      locationType: json['location_type'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      faceMatchConfidence: (json['face_match_confidence'] as num?)?.toDouble(),
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'worker_id': workerId,
      'worker_name': workerName,
      'photo_path': photoPath,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'status': status,
      'location_type': locationType,
      'latitude': latitude,
      'longitude': longitude,
      'face_match_confidence': faceMatchConfidence,
      'updated_at': updatedAt,
    };
  }
}

class ToolLibraryModel {
  final int toolId;
  final String toolName;
  final String toolCode;
  final String qrCode;
  final String category;
  final String status; // 'AVAILABLE', 'CHECKED_OUT', 'MAINTENANCE'
  final int? assignedToUserId;
  final String? assignedToUserName;
  final String? checkOutTime;
  final String? expectedReturnTime;
  final String? actualReturnTime;
  final String condition; // 'GOOD', 'FAIR', 'DAMAGED'
  final String location;
  final String updatedAt;

  ToolLibraryModel({
    required this.toolId,
    required this.toolName,
    required this.toolCode,
    required this.qrCode,
    required this.category,
    required this.status,
    this.assignedToUserId,
    this.assignedToUserName,
    this.checkOutTime,
    this.expectedReturnTime,
    this.actualReturnTime,
    required this.condition,
    required this.location,
    required this.updatedAt,
  });

  bool get isAvailable => status == 'AVAILABLE';
  bool get isCheckedOut => status == 'CHECKED_OUT';
  bool get isOverdue {
    if (expectedReturnTime == null || actualReturnTime != null) return false;
    try {
      return DateTime.parse(expectedReturnTime!).isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  factory ToolLibraryModel.fromJson(Map<String, dynamic> json) {
    return ToolLibraryModel(
      toolId: json['tool_id'] as int,
      toolName: json['tool_name'] as String,
      toolCode: json['tool_code'] as String,
      qrCode: json['qr_code'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      assignedToUserId: json['assigned_to_user_id'] as int?,
      assignedToUserName: json['assigned_to_user_name'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      expectedReturnTime: json['expected_return_time'] as String?,
      actualReturnTime: json['actual_return_time'] as String?,
      condition: json['condition'] as String,
      location: json['location'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tool_id': toolId,
      'tool_name': toolName,
      'tool_code': toolCode,
      'qr_code': qrCode,
      'category': category,
      'status': status,
      'assigned_to_user_id': assignedToUserId,
      'assigned_to_user_name': assignedToUserName,
      'check_out_time': checkOutTime,
      'expected_return_time': expectedReturnTime,
      'actual_return_time': actualReturnTime,
      'condition': condition,
      'location': location,
      'updated_at': updatedAt,
    };
  }
}

class OTPPermitModel {
  final int permitId;
  final String permitNumber;
  final int workerId;
  final String workerName;
  final String workType;
  final String hazardLevel; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final String location;
  final String startTime;
  final String? endTime;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED', 'COMPLETED'
  final int? safetyOfficerId;
  final String? safetyOfficerName;
  final String? otpCode;
  final bool isOTPVerified;
  final List<String> hazards;
  final List<String> safetyMeasures;
  final String? remarks;
  final String createdAt;
  final String updatedAt;

  OTPPermitModel({
    required this.permitId,
    required this.permitNumber,
    required this.workerId,
    required this.workerName,
    required this.workType,
    required this.hazardLevel,
    required this.location,
    required this.startTime,
    this.endTime,
    required this.status,
    this.safetyOfficerId,
    this.safetyOfficerName,
    this.otpCode,
    required this.isOTPVerified,
    required this.hazards,
    required this.safetyMeasures,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isCriticalHazard => hazardLevel == 'CRITICAL' || hazardLevel == 'HIGH';

  factory OTPPermitModel.fromJson(Map<String, dynamic> json) {
    return OTPPermitModel(
      permitId: json['permit_id'] as int,
      permitNumber: json['permit_number'] as String,
      workerId: json['worker_id'] as int,
      workerName: json['worker_name'] as String,
      workType: json['work_type'] as String,
      hazardLevel: json['hazard_level'] as String,
      location: json['location'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      status: json['status'] as String,
      safetyOfficerId: json['safety_officer_id'] as int?,
      safetyOfficerName: json['safety_officer_name'] as String?,
      otpCode: json['otp_code'] as String?,
      isOTPVerified: json['is_otp_verified'] as bool? ?? false,
      hazards: (json['hazards'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      safetyMeasures: (json['safety_measures'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permit_id': permitId,
      'permit_number': permitNumber,
      'worker_id': workerId,
      'worker_name': workerName,
      'work_type': workType,
      'hazard_level': hazardLevel,
      'location': location,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'safety_officer_id': safetyOfficerId,
      'safety_officer_name': safetyOfficerName,
      'otp_code': otpCode,
      'is_otp_verified': isOTPVerified,
      'hazards': hazards,
      'safety_measures': safetyMeasures,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PettyCashModel {
  final int expenseId;
  final int userId;
  final String userName;
  final String category; // 'TRANSPORT', 'FOOD', 'MATERIAL', 'MISC'
  final double amount;
  final String description;
  final String? receiptPath;
  final String expenseDate;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool isGPSVerified;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final int? approvedBy;
  final String? approverName;
  final String? approvalRemarks;
  final String createdAt;
  final String updatedAt;

  PettyCashModel({
    required this.expenseId,
    required this.userId,
    required this.userName,
    required this.category,
    required this.amount,
    required this.description,
    this.receiptPath,
    required this.expenseDate,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.isGPSVerified,
    required this.status,
    this.approvedBy,
    this.approverName,
    this.approvalRemarks,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get hasReceipt => receiptPath != null && receiptPath!.isNotEmpty;

  factory PettyCashModel.fromJson(Map<String, dynamic> json) {
    return PettyCashModel(
      expenseId: json['expense_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      receiptPath: json['receipt_path'] as String?,
      expenseDate: json['expense_date'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['location_name'] as String?,
      isGPSVerified: json['is_gps_verified'] as bool? ?? false,
      status: json['status'] as String,
      approvedBy: json['approved_by'] as int?,
      approverName: json['approver_name'] as String?,
      approvalRemarks: json['approval_remarks'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'user_id': userId,
      'user_name': userName,
      'category': category,
      'amount': amount,
      'description': description,
      'receipt_path': receiptPath,
      'expense_date': expenseDate,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'is_gps_verified': isGPSVerified,
      'status': status,
      'approved_by': approvedBy,
      'approver_name': approverName,
      'approval_remarks': approvalRemarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
