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
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      ownerId: json['owner_id'],
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
