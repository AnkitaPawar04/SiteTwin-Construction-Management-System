import 'package:hive/hive.dart';

part 'vendor_model.g.dart';

@HiveType(typeId: 12)
class VendorModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? contactPerson;
  
  @HiveField(3)
  final String? phone;
  
  @HiveField(4)
  final String? email;
  
  @HiveField(5)
  final String? address;
  
  @HiveField(6)
  final String? gstNumber;
  
  @HiveField(7)
  final String? panNumber;
  
  @HiveField(8)
  final String? vendorType; // 'GST' or 'NON_GST'
  
  @HiveField(9)
  final String createdAt;
  
  @HiveField(10)
  final String updatedAt;
  
  @HiveField(11)
  final bool isSynced;
  
  @HiveField(12)
  final String? localId;

  VendorModel({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.panNumber,
    this.vendorType,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
    this.localId,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: _parseId(json['id']),
      name: json['name']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      panNumber: json['pan_number']?.toString(),
      vendorType: json['vendor_type']?.toString(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'vendor_type': vendorType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
      'local_id': localId,
    };
  }

  VendorModel copyWith({
    int? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    String? panNumber,
    String? vendorType,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
    String? localId,
  }) {
    return VendorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      vendorType: vendorType ?? this.vendorType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
    );
  }

  bool get isGSTVendor => gstNumber != null && gstNumber!.isNotEmpty;
  bool get hasValidContact => phone != null || email != null;
}
