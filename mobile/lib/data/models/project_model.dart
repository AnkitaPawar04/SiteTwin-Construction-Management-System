class ProjectModel {
  final int id;
  final String name;
  final String location;
  final String? description;
  final double latitude;
  final double longitude;
  final int geofenceRadiusMeters;
  final String startDate;
  final String endDate;
  final int ownerId;
  
  ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.latitude,
    required this.longitude,
    this.geofenceRadiusMeters = 100,
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
      description: json['description']?.toString(),
      latitude: json['latitude'] is double ? json['latitude'] : double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: json['longitude'] is double ? json['longitude'] : double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      geofenceRadiusMeters: json['geofence_radius_meters'] is int ? json['geofence_radius_meters'] : int.tryParse(json['geofence_radius_meters']?.toString() ?? '100') ?? 100,
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
      if (description != null) 'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'geofence_radius_meters': geofenceRadiusMeters,
      'start_date': startDate,
      'end_date': endDate,
      'owner_id': ownerId,
    };
  }
}
