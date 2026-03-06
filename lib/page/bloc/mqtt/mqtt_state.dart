part of 'mqtt_bloc.dart';

@immutable
sealed class MqttState {}

class ProjectorState extends MqttState {
  final Map<String, ProjectorModel> projectorStats;
  final Map<String, List<FlSpot>> temperatureData;
  final Map<String, List<FlSpot>> humidityData;
  final Map<String, int> xValue;
  final Map<String, List<DateTime>> timeData;

  ProjectorState({
    required this.projectorStats,
    required this.temperatureData,
    required this.humidityData,
    required this.xValue,
    required this.timeData,
  });
}
