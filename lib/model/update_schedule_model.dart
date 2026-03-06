class ExceptionScheduleModel {
  int schedule_id;
  String exceptionDate;
  String newStartTime;
  String newEndTime;

  ExceptionScheduleModel({
    required this.schedule_id,
    required this.exceptionDate,
    required this.newStartTime,
    required this.newEndTime,
  });

  factory ExceptionScheduleModel.fromJson(Map<String, dynamic> json) {
    String formatTime(dynamic time) {
      if (time == null || time.toString().isEmpty) return '';
      String timeStr = time.toString();
      return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
    }

    return ExceptionScheduleModel(
      schedule_id: json['schedule_id'] ?? 0,
      exceptionDate: json['exception_date'] ?? '',
      newStartTime: formatTime(json['new_starttime']),
      newEndTime: formatTime(json['new_endtime']),
    );
  }
}
