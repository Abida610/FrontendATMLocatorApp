import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:dab_app/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class NavigationScreen extends StatefulWidget {
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late MapController _mapController;
  double? userLatitude;
  double? userLongitude;
  double? atmLatitude;
  double? atmLongitude;
  int? atmId;
  List<latlng.LatLng> _routePoints = [];
  String? _atmStatus;
  int? _distanceMeters;
  int? _travelTimeSeconds;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null ) {
      userLatitude = args['userLatitude'];
      userLongitude = args['userLongitude'];
      atmId = args['atmId'];

      if (_loading) _fetchRoute();
    }
  }

  Future<void> _fetchRoute() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = APIService();
      final response = await api.fetchNavigationRoute(
        userLatitude: userLatitude!,
        userLongitude: userLongitude!,
        atmId: atmId!,

      );
      setState(() {
        _routePoints = response.route['routes'][0]['legs'][0]['points']
            .map<latlng.LatLng>((point) => latlng.LatLng(point['latitude'], point['longitude']))
            .toList();
        if (_routePoints.isNotEmpty) {
          atmLatitude = _routePoints.last.latitude;
          atmLongitude = _routePoints.last.longitude;
        }

        _distanceMeters = response.route['routes'][0]['summary']['lengthInMeters'];
        _travelTimeSeconds = response.route['routes'][0]['summary']['travelTimeInSeconds'];
        _atmStatus = response.atmStatus;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Navigation vers DAB')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Navigation vers DAB')),
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation vers DAB'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latlng.LatLng(userLatitude!, userLongitude!),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}',
                  additionalOptions: {
                    'subscriptionKey': '',
                  },

                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlng.LatLng(userLatitude!, userLongitude!),
                      child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                    Marker(
                      point: latlng.LatLng(atmLatitude!, atmLongitude!),
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails du trajet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Distance: ${(_distanceMeters! / 1000).toStringAsFixed(2)} km'),
                  Text('Temps de trajet: ${(_travelTimeSeconds! / 60).floor()} min ${(_travelTimeSeconds! % 60)} s'),
                  Text('Statut du DAB: ${_atmStatus ?? 'N/A'}'),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.report_problem),
                    label: Text('Ajouter réclamation'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/complaints', arguments: {
                        'atmId': atmId,
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}