import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:skripsi_iot_projector/page/schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skripsi_iot_projector/model/schedule_model.dart';

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
      final String matkul = row[1]?.value.toString() ?? "";

      if (matkul.isNotEmpty) {
        schedules.add({
          'classroom': row[0]?.value.toString() ?? "",
          'mata_kuliah': matkul,
          'hari': row[2]?.value.toString() ?? "",
          'start_time': row[3]?.value.toString() ?? "",
          'end_time': row[4]?.value.toString() ?? "",
        });
      }
    }
  }
  return schedules;
}

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final supabase = Supabase.instance.client;

  ScheduleBloc() : super(ScheduleInitial()) {
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

        await supabase.from('tbl_jadwalkelas').insert(schedules);

        print("Uploaded file: ${event.file.name}");

        add(LoadScheduleEvent());
      } catch (e) {
        emit(ScheduleFailure('Gagal mengunggah jadwal: $e'));
      }
    });

    on<LoadScheduleEvent>((event, emit) async {
      const days = {
        1: 'Senin',
        2: 'Selasa',
        3: 'Rabu',
        4: 'Kamis',
        5: 'Jumat',
        6: 'Sabtu',
      };

      emit(ScheduleLoading());
      print("Loading schedule data from database...");
      try {
        final result = await supabase.from('tbl_jadwalkelas').select();
        print("Loaded schedule data: $result");
        if (result == null || (result is List && result.isEmpty)) {
          emit(ScheduleInitial());
        } else {
          List<ScheduleModel> wholeSchedule = (result as List)
              .map((json) => ScheduleModel.fromJson(json))
              .toList();

          List<ScheduleModel> getTodaySchedule = wholeSchedule
              .where((s) => s.hari == days[DateTime.now().weekday])
              .toList();

          emit(ScheduleLoaded(wholeSchedule, getTodaySchedule));
        }
      } catch (e) {
        print("Error loading schedule: $e");
        emit(ScheduleFailure('Gagal memuat jadwal: $e'));
      }
    });

    on<CalendarDateSelectedEvent>((event, emit) async {
      emit(SelectCalendarDateLoading(event.wholeSchedule));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(
        SelectCalendarDateLoaded(
          event.wholeSchedule,
          event.scheduleForSelectedDay,
        ),
      );
    });
  }
}
