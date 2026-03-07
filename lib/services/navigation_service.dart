import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NavigationService {
  // Nominatim for Search
  Future<LatLng?> searchPlace(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'SmartDriveApp/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Search Error: $e');
    }
    return null;
  }

  // OSRM for Routing
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          return coordinates
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Route Error: $e');
    }
    return [];
  }

  // Overpass API for Speed Limits
  Future<int?> getSpeedLimit(LatLng pos) async {
    // Search within 20 meters
    final query =
        """
    [out:json];
    way(around:20, ${pos.latitude}, ${pos.longitude})["maxspeed"];
    out tags;
    """;
    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['elements'] != null && (data['elements'] as List).isNotEmpty) {
          final elements = data['elements'] as List;
          for (var el in elements) {
            if (el['tags'] != null && el['tags']['maxspeed'] != null) {
              final speedStr = el['tags']['maxspeed'].toString();
              // Handle "50 mph" vs "50"
              final speed = int.tryParse(
                speedStr.replaceAll(RegExp(r'[^0-9]'), ''),
              );
              return speed;
            }
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Speed Limit Error: $e');
    }
    return null;
  }

  // Get Nearby POIs (Hospitals, Rest Areas)
  Future<List<Map<String, dynamic>>> getNearbyPOIs(
    LatLng center,
    String type,
  ) async {
    // type can be 'hospital' or 'rest_area'
    final query =
        """
    [out:json];
    (
      node["amenity"="$type"](around:5000, ${center.latitude}, ${center.longitude});
      way["amenity"="$type"](around:5000, ${center.latitude}, ${center.longitude});
    );
    out center;
    """;
    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['elements'] != null) {
          final elements = data['elements'] as List;
          return elements
              .map((el) {
                final lat = el['lat'] ?? el['center']?['lat'];
                final lon = el['lon'] ?? el['center']?['lon'];
                final name = el['tags']?['name'] ?? 'Unknown';
                return {'name': name, 'lat': lat, 'lon': lon};
              })
              .where((poi) => poi['lat'] != null && poi['lon'] != null)
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('POI Error: $e');
    }
    return [];
  }
}
