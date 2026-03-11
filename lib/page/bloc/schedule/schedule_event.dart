part of 'schedule_bloc.dart';

@immutable
sealed class ScheduleEvent {}

// Choose schedule file from device
final class PickScheduleFileEvent extends ScheduleEvent {
  PlatformFile file;
  PickScheduleFileEvent(this.file);
}

// Upload processed schedule from excel to database
final class UploadScheduleEvent extends ScheduleEvent {
  PlatformFile file;
  UploadScheduleEvent(this.file);
}

// Reset file selection
final class ResetFileSelectionEvent extends ScheduleEvent {}

// Fetch schedule data from database
final class LoadScheduleEvent extends ScheduleEvent {}

final class CalendarDateSelectedEvent extends ScheduleEvent {
  final DateTime selectedDate;
  final List<ScheduleModel> scheduleForSelectedDay;
  final List<ScheduleModel> wholeSchedule;
  CalendarDateSelectedEvent({
    required this.selectedDate,
    required this.scheduleForSelectedDay,
    required this.wholeSchedule,
  });
}

final class UpdateScheduleEvent extends ScheduleEvent {
  final ScheduleModel schedule;
  final DateTime updatedScheduleDate;
  final String newStartTime;
  final String newEndTime;

  UpdateScheduleEvent({
    required this.schedule,
    required this.updatedScheduleDate,
    required this.newStartTime,
    required this.newEndTime,
  });
}

final class ReplaceScheduleEvent extends ScheduleEvent {}

class RefetchScheduleMqttEvent extends ScheduleEvent {}
