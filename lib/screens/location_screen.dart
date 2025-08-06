import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashLocationScreen extends StatefulWidget {
  @override
  _SplashLocationScreenState createState() => _SplashLocationScreenState();
}

class _SplashLocationScreenState extends State<SplashLocationScreen> {
  bool _loading = true;
  String? _error;
  latlng.LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  final String azureMapsKey = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndFetchLocation();
  }

  Future<void> _checkPermissionAndFetchLocation() async {
    PermissionStatus permission = await Permission.location.status;

    if (permission.isGranted) {
      _getCurrentLocation();
    } else {
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    PermissionStatus result = await Permission.location.request();

    if (result.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _loading = false;
        _error = 'La permission de localisation n\'a pas été accordée. Veuillez l\'activer ou choisir manuellement.';
        _selectedLocation = latlng.LatLng(36.80689963553058, 10.180460577379366); // Default to Tunis
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = latlng.LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedLocation!, 14.0);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Impossible d'obtenir la localisation : $e";
        _loading = false;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une adresse')),
      );
      return;
    }

    final url = Uri.parse(
        'https://atlas.microsoft.com/search/address/json?api-version=1.0&subscription-key=$azureMapsKey&query=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final position = result['position'];
          setState(() {
            _selectedLocation = latlng.LatLng(position['lat'], position['lon']);
            _mapController.move(_selectedLocation!, 14.0);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucune localisation trouvée pour cette adresse')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = "Erreur lors de la recherche d'adresse : $e";
      });
    }
  }

  void _goToHomeScreen(double latitude, double longitude) {
    Navigator.pushReplacementNamed(
      context,
      '/home_map',
      arguments: {'latitude': latitude, 'longitude': longitude},
    );
  }

  void _selectLocationOnMap(latlng.LatLng point) {
    setState(() {
      _selectedLocation = point;
      _mapController.move(_selectedLocation!, 14.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Sélectionnez votre localisation')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sélectionnez votre localisation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Rechercher une adresse",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => _searchAddress(_searchController.text),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _requestPermission();
                  },
                  child: Text("Utiliser ma position actuelle"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? latlng.LatLng(36.80689963553058, 10.180460577379366), // Default to Tunis
                initialZoom: 14.0,
                onTap: (tapPosition, point) => _selectLocationOnMap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}',
                  additionalOptions: {
                    'subscriptionKey': azureMapsKey,
                  },
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedLocation != null
                  ? () => _goToHomeScreen(_selectedLocation!.latitude, _selectedLocation!.longitude)
                  : null,
              child: Text("Valider la position"),
            ),
          ),
        ],
      ),
    );
  }
}