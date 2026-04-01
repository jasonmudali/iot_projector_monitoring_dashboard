import 'package:flutter/foundation.dart';

class LampUsageHoursModel {
  String classroom;
  int hours;

  LampUsageHoursModel({required this.classroom, required this.hours});

  factory LampUsageHoursModel.fromJson(Map<String, dynamic> json) {
    return LampUsageHoursModel(
      classroom: json['classroom'] ?? '',
      hours: json['lamphour_usage'] ?? 0,
    );
  }
}
