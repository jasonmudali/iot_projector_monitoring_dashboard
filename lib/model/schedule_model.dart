class ScheduleModel {
  String hari;
  String classroom;
  String mata_kuliah;
  String start_time;
  String end_time;

  ScheduleModel({
    required this.hari,
    required this.classroom,
    required this.mata_kuliah,
    required this.start_time,
    required this.end_time,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      hari: json['hari'] ?? '',
      classroom: json['classroom'] ?? '',
      mata_kuliah: json['mata_kuliah'] ?? '',
      start_time: json['start_time'] ?? '',
      end_time: json['end_time'] ?? '',
    );
  }
}
