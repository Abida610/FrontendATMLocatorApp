class NavigationResponse {
  final Map<String, dynamic> route;
  final String atmStatus;

  NavigationResponse({required this.route, required this.atmStatus});

  factory NavigationResponse.fromJson(Map<String, dynamic> json) {
    return NavigationResponse(
      route: json['route'] as Map<String, dynamic>,
      atmStatus: json['atm_status'],
    );
  }
  List<Map<String, double>> getRoutePoints() {
    final points = ((route['routes']?[0]?['legs']?[0]?['points'] as List?) ?? []);
    return points.map<Map<String, double>>((p) => {
      "lat": (p['latitude'] as num).toDouble(),
      "lng": (p['longitude'] as num).toDouble(),
    }).toList();
  }
}
