part of 'mqtt_bloc.dart';

@immutable
sealed class MqttEvent {}

class StartListening extends MqttEvent {}

class NewMqttData extends MqttEvent {
  final Map<String, dynamic> data;
  NewMqttData(this.data);
}
