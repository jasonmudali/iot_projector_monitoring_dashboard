part of 'mqtt_bloc.dart';

@immutable
sealed class MqttEvent {}

class StartListening extends MqttEvent {}

class NewMqttData extends MqttEvent {
  final Map<String, dynamic> data;
  NewMqttData(this.data);
}

class ChangeModeEvent extends MqttEvent {
  final String roomId;
  final String mode; // "live", "1h", "24h"
  ChangeModeEvent(this.roomId, this.mode);
}

class SetHistoricalDataEvent extends MqttEvent {
  final String roomId;
  final String duration; // "1h", "24h"
  final List<FlSpot> tempData;
  final List<FlSpot> humidData;
  final List<DateTime> timeData;

  SetHistoricalDataEvent({
    required this.roomId,
    required this.duration,
    required this.tempData,
    required this.humidData,
    required this.timeData,
  });
}

class CalibrateLuxValueEvent extends MqttEvent {}
