class ProjectModel {
  final int id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String startDate;
  final String endDate;
  final int ownerId;
  
  ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
  });
  
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final start = json['start_date']?.toString() ?? '';
    final end = json['end_date']?.toString() ?? '';
    return ProjectModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      latitude: json['latitude'] is double ? json['latitude'] : double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: json['longitude'] is double ? json['longitude'] : double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      startDate: start,
      endDate: end,
      ownerId: json['owner_id'] is int ? json['owner_id'] : int.tryParse(json['owner_id']?.toString() ?? '0') ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'start_date': startDate,
      'end_date': endDate,
      'owner_id': ownerId,
    };
  }
}
