part of 'mqtt_bloc.dart';

@immutable
sealed class MqttState {}

class ProjectorState extends MqttState {
  final Map<String, ProjectorModel> projectorStats;

  // Live data
  final Map<String, List<FlSpot>> temperatureData;
  final Map<String, List<FlSpot>> humidityData;
  final Map<String, int> xValue;
  final Map<String, List<DateTime>> timeData;

  // Historical data: {roomId: {duration: [data]}}
  final Map<String, Map<String, List<FlSpot>>> historicalTempData;
  final Map<String, Map<String, List<FlSpot>>> historicalHumidData;
  final Map<String, Map<String, List<DateTime>>> historicalTimeData;

  // Track current mode per room: {roomId: "live|1h|24h"}
  final Map<String, String> currentMode;

  ProjectorState({
    required this.projectorStats,
    required this.temperatureData,
    required this.humidityData,
    required this.xValue,
    required this.timeData,
    required this.historicalTempData,
    required this.historicalHumidData,
    required this.historicalTimeData,
    required this.currentMode,
  });

  // Helper methods to get displayed data based on mode
  List<FlSpot>? getDisplayTemperatureData(String roomId) {
    final mode = currentMode[roomId] ?? "live";
    if (mode == "live") {
      return temperatureData[roomId];
    }
    final data = historicalTempData[roomId]?[mode];
    return data;
  }

  List<FlSpot>? getDisplayHumidityData(String roomId) {
    final mode = currentMode[roomId] ?? "live";
    if (mode == "live") {
      return humidityData[roomId];
    }
    final data = historicalHumidData[roomId]?[mode];
    return data;
  }

  List<DateTime>? getDisplayTimeData(String roomId) {
    final mode = currentMode[roomId] ?? "live";
    if (mode == "live") {
      return timeData[roomId];
    }
    final data = historicalTimeData[roomId]?[mode];
    return data;
  }

  double? getAverageTemperatureValue(String roomId) {
    final mode = currentMode[roomId] ?? "live";
    if (mode == "live") {
      final tempData = temperatureData[roomId];
      if (tempData != null && tempData.isNotEmpty) {
        return tempData.map((e) => e.y).reduce((a, b) => a + b) /
            tempData.length;
      }
    } else {
      final tempData = historicalTempData[roomId]?[mode];
      if (tempData != null && tempData.isNotEmpty) {
        return tempData.map((e) => e.y).reduce((a, b) => a + b) /
            tempData.length;
      }
    }
    return null;
  }

  double? getAverageHumidityValue(String roomId) {
    final mode = currentMode[roomId] ?? "live";
    if (mode == "live") {
      final humidData = humidityData[roomId];
      if (humidData != null && humidData.isNotEmpty) {
        return humidData.map((e) => e.y).reduce((a, b) => a + b) /
            humidData.length;
      }
    } else {
      final humidData = historicalHumidData[roomId]?[mode];
      if (humidData != null && humidData.isNotEmpty) {
        return humidData.map((e) => e.y).reduce((a, b) => a + b) /
            humidData.length;
      }
    }
    return null;
  }
}

class CalibratingLuxValueState extends MqttState {}

class CalibratedLuxValueState extends MqttState {}
