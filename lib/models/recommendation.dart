class ATMRecommendation {
  final int pid;
  final String name;
  final String city;
  final String latestStatus;
  final String criticalLevel;
  final DateTime lastUpdated;
  final double distance;

  ATMRecommendation({
    required this.pid,
    required this.name,
    required this.city,
    required this.latestStatus,
    required this.criticalLevel,
    required this.lastUpdated,
    required this.distance,
  });

  factory ATMRecommendation.fromJson(Map<String, dynamic> json) {
    return ATMRecommendation(
      pid: json['pid'],
      name: json['name'],
      city: json['city'],
      latestStatus: json['latest_status'],
      criticalLevel: json['critical_level'],
      lastUpdated: DateTime.parse(json['last_updated']),
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
