import 'package:flutter/foundation.dart';

class LampUsageHoursModel {
  String classroom;
  int hours;

  LampUsageHoursModel({required this.classroom, required this.hours});

  factory LampUsageHoursModel.fromJson(Map<String, dynamic> json) {
    return LampUsageHoursModel(
      classroom: json['classroom'] ?? '',
      hours: (json['lamphour_usage'] as num?) != null
          ? ((json['lamphour_usage'] as num).toInt() / 60).toInt()
          : 0,
    );
  }
}
