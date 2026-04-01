class ProjectorModel {
  final String id;
  final String status;
  final double temperature;
  final double humidity;

  ProjectorModel({
    this.id = "HD3",
    this.status = "OFF",
    this.temperature = 0.0,
    this.humidity = 0.0,
  });

  factory ProjectorModel.fromJson(Map<String, dynamic> json) {
    return ProjectorModel(
      id: json['device_id'] ?? "HD3",
      status: json['status'] ?? "OFF",
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'temperature': temperature,
      'humidity': humidity,
    };
  }
}
