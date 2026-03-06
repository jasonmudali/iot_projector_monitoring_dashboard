class ScheduleModel {
  int id;
  String hari;
  DateTime tanggal;
  String classroom;
  String mataKuliah;
  String startTime;
  String endTime;

  ScheduleModel({
    required this.id,
    required this.hari,
    required this.tanggal,
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
      id: json['id'] ?? 0,
      hari: json['hari'] ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : DateTime.now(),
      classroom: json['classroom'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      startTime: formatTime(json['start_time']),
      endTime: formatTime(json['end_time']),
    );
  }

  // ScheduleModel copyWith({
  //   int? id,
  //   String? mataKuliah,
  //   String? classroom,
  //   String? startTime,
  //   String? endTime,
  //   String? hari,
  //   DateTime? tanggal,
  // }) {
  //   return ScheduleModel(
  //     id: id ?? this.id,
  //     mataKuliah: mataKuliah ?? this.mataKuliah,
  //     classroom: classroom ?? this.classroom,
  //     startTime: startTime ?? this.startTime,
  //     endTime: endTime ?? this.endTime,
  //     hari: hari ?? this.hari,
  //   );
  // }
}
