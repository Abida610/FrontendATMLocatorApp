import 'package:flutter/material.dart';
import 'package:dab_app/models/recommendation.dart';
import 'package:dab_app/services/api_service.dart';

class RecommendedATMsScreen extends StatefulWidget {
  @override
  State<RecommendedATMsScreen> createState() => _RecommendedATMsScreenState();
}

class _RecommendedATMsScreenState extends State<RecommendedATMsScreen> {
  late double userLat, userLng;
  late Future<List<ATMRecommendation>> _futureATMs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    userLat = args?['latitude'] ?? 0;
    userLng = args?['longitude'] ?? 0;

    _futureATMs = APIService().fetchATMRecommendations(
      latitude: userLat,
      longitude: userLng,
    );
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
        return Colors.grey; // Default color if unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DABs recommandés')),
      body: FutureBuilder<List<ATMRecommendation>>(
        future: _futureATMs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(snapshot.error.toString().replaceAll('Exception: ', '')),
                  duration: Duration(seconds: 3), // Adjust duration as needed
                ),
              );
            });
            return Center(child: Text('Chargement des recommandations...')); // Placeholder while SnackBar shows
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun DAB trouvé dans la zone spécifiée.'));
          }

          final atms = snapshot.data!;
          return ListView.separated(
            itemCount: atms.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, idx) {
              final atm = atms[idx];
              return ListTile(
                title: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCriticalLevelColor(atm.criticalLevel),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8), // Space between dot and name
                    Expanded( // Allows text to use available space
                      child: Text(
                        atm.name,
                        overflow: TextOverflow.ellipsis, // Truncates long text
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statut : ${atm.latestStatus}'),
                    Text('Distance : ${atm.distance.toStringAsFixed(2)} km'),
                  ],
                ),
                trailing: ElevatedButton.icon(
                  icon: Icon(Icons.navigation),
                  label: Text('Naviguer'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/navigation', arguments: {
                      'userLatitude': userLat,
                      'userLongitude': userLng,
                      'atmId': atm.pid,
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}