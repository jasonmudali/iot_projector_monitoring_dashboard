part of 'mqtt_bloc.dart';

@immutable
sealed class MqttState {}

class ProjectorState extends MqttState {
  final Map<String, ProjectorModel> projectorStats;

  ProjectorState({required this.projectorStats});
}
