class ScheduleModel {
  String hari;
  String classroom;
  String mataKuliah;
  String startTime;
  String endTime;

  ScheduleModel({
    required this.hari,
    required this.classroom,
    required this.mataKuliah,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    String formatTime(dynamic time) {
      if (time == null || time.toString().isEmpty) return '';
      String timeStr = time.toString();
      return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
    }

    return ScheduleModel(
      hari: json['hari'] ?? '',
      classroom: json['classroom'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      startTime: formatTime(json['start_time']),
      endTime: formatTime(json['end_time']),
    );
  }
}
