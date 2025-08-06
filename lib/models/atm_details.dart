class ATMDetails {
  final int pid;
  final String name;
  final String city;
  final String latestStatus;
  final String criticalLevel;
  final DateTime lastUpdated;
  final String? avgCommunicationDowntime;
  final double? avgServiceDowntime;
  final DateTime? statLastUpdated;
  final double longitude;
  final double latitude;

  ATMDetails({
    required this.pid,
    required this.name,
    required this.city,
    required this.latestStatus,
    required this.criticalLevel,
    required this.lastUpdated,
    this.avgCommunicationDowntime,
    this.avgServiceDowntime,
    this.statLastUpdated,
    required this.longitude,
    required this.latitude,
  });

  factory ATMDetails.fromJson(Map<String, dynamic> json) {
    return ATMDetails(
      pid: json['pid'],
      name: json['name'],
      city: json['city'],
      latestStatus: json['latest_status'],
      criticalLevel: json['critical_level'],
      lastUpdated: DateTime.parse(json['last_updated']),
      avgCommunicationDowntime: json['avg_communication_downtime'],
      avgServiceDowntime: json['avg_service_downtime']?.toDouble(),
      statLastUpdated: json['stat_last_updated'] != null ? DateTime.parse(json['stat_last_updated']) : null,
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
    );
  }
}
