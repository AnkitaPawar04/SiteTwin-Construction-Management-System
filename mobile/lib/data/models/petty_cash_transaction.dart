class PettyCashTransaction {
  final int id;
  final int walletId;
  final int userId;
  final String userName;
  final double amount;
  final String description;
  final String receiptImage;
  final String imageHash;
  final double? latitude;
  final double? longitude;
  final String gpsStatus; // ON_SITE, OUTSIDE_SITE
  final bool duplicateFlag;
  final String status; // PENDING, APPROVED, REJECTED
  final DateTime createdAt;
  final String? managerComment;
  final DateTime? reviewedAt;

  PettyCashTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.receiptImage,
    required this.imageHash,
    this.latitude,
    this.longitude,
    required this.gpsStatus,
    required this.duplicateFlag,
    required this.status,
    required this.createdAt,
    this.managerComment,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'user_id': userId,
      'user_name': userName,
      'amount': amount,
      'description': description,
      'receipt_image': receiptImage,
      'image_hash': imageHash,
      'latitude': latitude,
      'longitude': longitude,
      'gps_status': gpsStatus,
      'duplicate_flag': duplicateFlag,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'manager_comment': managerComment,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  factory PettyCashTransaction.fromJson(Map<String, dynamic> json) {
    return PettyCashTransaction(
      id: json['id'],
      walletId: json['wallet_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      receiptImage: json['receipt_image'],
      imageHash: json['image_hash'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      gpsStatus: json['gps_status'],
      duplicateFlag: json['duplicate_flag'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      managerComment: json['manager_comment'],
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.parse(json['reviewed_at']) 
          : null,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isOnSite => gpsStatus == 'ON_SITE';
  bool get hasIssues => duplicateFlag || gpsStatus == 'OUTSIDE_SITE';
}
