import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:dab_app/services/api_service.dart';
import 'package:dab_app/models/atm_details.dart';

class HomeMapScreen extends StatefulWidget {
  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  late MapController _mapController;
  double? userLat;
  double? userLng;

  Set<Marker> _markers = {};
  List<ATMDetails> _atms = [];
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
    if (args != null && (userLat == null || userLng == null)) {
      userLat = args['latitude'];
      userLng = args['longitude'];
      if (_loading) _fetchATMs();
    }
  }

  Color _getCriticalLevelColor(String criticalLevel) {
    switch (criticalLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'warning':
        return Colors.yellow;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _fetchATMs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = APIService();
      final atms = await api.fetchAllATMs();
      _atms = atms;
      _markers = atms
          .map((atm) => Marker(
        point: latlng.LatLng(
          atm.latitude,
          atm.longitude,
        ),
        child: GestureDetector(
          onTap: () => _showATMDetails(atm),
          child: Icon(
            Icons.location_pin,
            color: _getCriticalLevelColor(atm.criticalLevel),
            size: 30,
          ),
        ),
      ))
          .toSet();
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _showATMDetails(ATMDetails atm) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ATMDetailsSheet(
        atm: atm,
        userLatitude: userLat!,
        userLongitude: userLng!,
      ),
    );
  }

  void _navigateToRecommendation() {
    Navigator.pushNamed(context, '/recommandation', arguments: {
      'latitude': userLat,
      'longitude': userLng,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Carte des DABs')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Carte des DABs')),
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des DABs'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: latlng.LatLng(userLat!, userLng!),
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
              MarkerLayer(markers: _markers.toList()),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton.icon(
              icon: Icon(Icons.list),
              label: Text('Recommander un DAB'),
              onPressed: _navigateToRecommendation,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: _fetchATMs,
        tooltip: 'Rafraîchir les DABs',
      ),
    );
  }
}

class ATMDetailsSheet extends StatelessWidget {
  final ATMDetails atm;
  final double userLatitude;
  final double userLongitude;

  const ATMDetailsSheet({
    super.key,
    required this.atm,
    required this.userLatitude,
    required this.userLongitude,
  });

  Color _getCriticalLevelColor(String criticalLevel) {
    switch (criticalLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'warning':
        return Colors.yellow;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 20,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCriticalLevelColor(atm.criticalLevel),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text("ATM: ${atm.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            SizedBox(height: 20),
            Text("Ville: ${atm.city ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            SizedBox(width: 20),
            Text("Statut: ${atm.latestStatus ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("Dernière mise à jour: ${atm.lastUpdated.toLocal()}", style: TextStyle(fontSize: 16)),
            if (atm.avgCommunicationDowntime != null)
              Text("Temps d'arrêt communication: ${atm.avgCommunicationDowntime}", style: TextStyle(fontSize: 16)),
            if (atm.avgServiceDowntime != null)
              Text("Temps d'arrêt service: ${atm.avgServiceDowntime}", style: TextStyle(fontSize: 16)),
            if (atm.statLastUpdated != null)
              Text("Statistiques mises à jour: ${atm.statLastUpdated!.toLocal()}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.navigation),
              label: Text('Naviguer vers ce DAB'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/navigation', arguments: {
                  'userLatitude': userLatitude,
                  'userLongitude': userLongitude,
                  'atmId': atm.pid,
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.report_problem),
              label: Text('Ajouter réclamation'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/complaints', arguments: {
                  'atmId': atm.pid,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}