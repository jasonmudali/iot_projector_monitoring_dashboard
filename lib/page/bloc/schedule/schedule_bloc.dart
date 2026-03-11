import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:skripsi_iot_projector/model/update_schedule_model.dart';
import 'package:skripsi_iot_projector/repository/mqtt_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skripsi_iot_projector/model/schedule_model.dart';
import 'package:intl/intl.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

List<Map<String, dynamic>> _parseExcelLogic(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  final String sheetName = excel.tables.keys.first;
  final table = excel.tables[sheetName];

  List<Map<String, dynamic>> schedules = [];

  if (table != null) {
    for (int i = 1; i < table.maxRows; i++) {
      final row = table.rows[i];

      final String classroom = row[0]?.value.toString() ?? "";
      final String matkul = row[1]?.value.toString() ?? "";
      final String hari = row[2]?.value.toString() ?? "";
      var tanggal = row[3]?.value ?? "";
      final String startTime = row[4]?.value.toString() ?? "";
      final String endTime = row[5]?.value.toString() ?? "";

      String formattedDate = "";

      if (tanggal.toString().contains('T')) {
        DateTime parsedDate = DateTime.parse(tanggal.toString());
        formattedDate = parsedDate.toIso8601String();
      }

      if (matkul.isNotEmpty) {
        schedules.add({
          'classroom': classroom,
          'mata_kuliah': matkul,
          'hari': hari,
          'tanggal': formattedDate,
          'start_time': startTime,
          'end_time': endTime,
        });
      }
    }
  }
  return schedules;
}

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final supabase = Supabase.instance.client;
  final MqttRepository mqttRepository;

  ScheduleBloc(this.mqttRepository) : super(ScheduleInitial()) {
    on<PickScheduleFileEvent>((event, emit) {
      emit(ScheduleFileSelected(event.file));
    });

    on<ResetFileSelectionEvent>((event, emit) {
      emit(ScheduleInitial());
    });

    on<UploadScheduleEvent>((event, emit) async {
      print("Uploading file: ${event.file.name}");
      emit(UploadScheduleLoading(event.file));

      await Future.delayed(const Duration(milliseconds: 50));

      try {
        final bytes = event.file.bytes;
        final schedules = await compute(_parseExcelLogic, bytes!);

        final result = await supabase
            .from('tbl_jadwalkelas')
            .insert(schedules)
            .select();

        if (result.isNotEmpty) {
          print("Schedule data inserted successfully: $result");
        } else {
          print("No data was inserted.");
        }

        add(LoadScheduleEvent());
      } catch (e) {
        emit(ScheduleFailure('Gagal mengunggah jadwal: $e'));
      }
    });

    on<LoadScheduleEvent>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final result = await supabase.from('tbl_jadwalkelas').select();

        if (result == null || (result is List && result.isEmpty)) {
          emit(ScheduleInitial());
        } else {
          List<ScheduleModel> wholeSchedule = (result as List)
              .map((json) => ScheduleModel.fromJson(json))
              .toList();

          List<ScheduleModel> getTodaySchedule = wholeSchedule
              .where(
                (s) =>
                    DateFormat('yyyy-MM-dd').format(s.tanggal) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
              )
              .toList();

          Map<String, List<ScheduleModel>> groupedToday = {};
          for (var s in getTodaySchedule) {
            if (!groupedToday.containsKey(s.startTime)) {
              groupedToday[s.startTime] = [];
            }
            groupedToday[s.startTime]!.add(s);
          }

          var sortedKeys = groupedToday.keys.toList()..sort();
          Map<String, List<ScheduleModel>> sortedGroupedToday = {
            for (var key in sortedKeys) key: groupedToday[key]!,
          };

          emit(
            ScheduleLoaded(wholeSchedule, getTodaySchedule, sortedGroupedToday),
          );
        }
      } catch (e) {
        print("Error loading schedule: $e");
        emit(ScheduleFailure('Gagal memuat jadwal: $e'));
      }
    });

    on<CalendarDateSelectedEvent>((event, emit) async {
      emit(SelectCalendarDateLoading(event.wholeSchedule));

      await Future.delayed(const Duration(milliseconds: 100));

      Map<String, List<ScheduleModel>> groupedToday = {};
      for (var s in event.scheduleForSelectedDay) {
        if (!groupedToday.containsKey(s.startTime)) {
          groupedToday[s.startTime] = [];
        }
        groupedToday[s.startTime]!.add(s);
      }

      var sortedKeys = groupedToday.keys.toList()..sort();
      Map<String, List<ScheduleModel>> sortedGroupedToday = {
        for (var key in sortedKeys) key: groupedToday[key]!,
      };

      emit(
        SelectCalendarDateLoaded(
          event.wholeSchedule,
          event.scheduleForSelectedDay,
          sortedGroupedToday,
        ),
      );
    });

    on<UpdateScheduleEvent>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final result = await supabase
            .from('tbl_jadwalkelas')
            .update({
              // 'hari': DateFormat('EEEE', 'id_ID').format(event.updatedScheduleDate),
              // 'tanggal': DateFormat('yyyy-MM-dd').format(event.updatedScheduleDate),
              'start_time': event.newStartTime,
              'end_time': event.newEndTime,
            })
            .eq('id', event.schedule.id)
            .select();
        if (result.isNotEmpty) {
          print("Schedule updated successfully: $result");
          add(LoadScheduleEvent());
        } else {
          print("No schedule was updated.");
        }
        add(RefetchScheduleMqttEvent());
      } catch (e) {
        print("Error updating schedule: $e");
        emit(ScheduleFailure('Gagal memperbarui jadwal: $e'));
      }
    });

    on<ReplaceScheduleEvent>((event, emit) async {
      emit(ScheduleLoading());
      try {
        await supabase.rpc('reset_jadwalkelas');
        print("All schedules deleted and ID counter reset successfully.");
        add(LoadScheduleEvent());
      } catch (e) {
        print("Error resetting schedules: $e");
        emit(ScheduleFailure('Gagal menghapus jadwal: $e'));
      }
    });

    on<RefetchScheduleMqttEvent>((event, emit) {
      mqttRepository.triggerRefetchSchedule();
    });
  }
}
