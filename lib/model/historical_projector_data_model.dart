class HistoricalProjectorDataModel {
  final DateTime createdAt;
  final double temperature;
  final double humidity;

  HistoricalProjectorDataModel({
    required this.createdAt,
    required this.temperature,
    required this.humidity,
  });

  factory HistoricalProjectorDataModel.fromJson(Map<String, dynamic> json) {
    return HistoricalProjectorDataModel(
      createdAt: DateTime.parse(json['created_at']),
      temperature: (json['temp'] ?? 0).toDouble(),
      humidity: (json['humid'] ?? 0).toDouble(),
    );
  }
}
