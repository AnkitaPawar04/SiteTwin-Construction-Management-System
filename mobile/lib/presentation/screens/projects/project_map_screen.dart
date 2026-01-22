import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/data/models/project_model.dart';

class ProjectMapScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectMapScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final projectLocation = LatLng(project.latitude, project.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('view_on_map')),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: projectLocation,
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.construction.mobile',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: projectLocation,
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            project.location,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.location_on, color: Colors.red, size: 24),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
