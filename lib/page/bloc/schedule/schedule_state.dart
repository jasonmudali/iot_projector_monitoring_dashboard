part of 'schedule_bloc.dart';

@immutable
sealed class ScheduleState {}

final class ScheduleInitial extends ScheduleState {}

final class ScheduleFileSelected extends ScheduleState {
  final PlatformFile file;
  ScheduleFileSelected(this.file);
}

final class UploadScheduleLoading extends ScheduleState {
  final PlatformFile file;
  UploadScheduleLoading(this.file);
}

// Displaying schedule to calendar
final class ScheduleLoaded extends ScheduleState {
  final List<ScheduleModel> wholeSchedule;
  final DateTime selectedDate;
  final List<ScheduleModel> selectedDaySchedule;
  final Map<String, List<ScheduleModel>> groupedTodaySchedule;

  ScheduleLoaded(
    this.wholeSchedule,
    this.selectedDate,
    this.selectedDaySchedule,
    this.groupedTodaySchedule,
  );
}

// Get schedule data from database
final class ScheduleLoading extends ScheduleState {}

final class ScheduleLoadedEmpty extends ScheduleState {}

final class ScheduleFailure extends ScheduleState {
  final String error;
  ScheduleFailure(this.error);
}

// Loading when selecting date on calendar
final class SelectCalendarDateLoading extends ScheduleState {
  final List<ScheduleModel> wholeSchedule;
  SelectCalendarDateLoading(this.wholeSchedule);
}

// Loaded schedule data after selecting date on calendar
final class SelectCalendarDateLoaded extends ScheduleState {
  final List<ScheduleModel> wholeSchedule;
  final DateTime selectedDate;
  final List<ScheduleModel> selectedDaySchedule;
  final Map<String, List<ScheduleModel>> groupedTodaySchedule;

  SelectCalendarDateLoaded(
    this.wholeSchedule,
    this.selectedDate,
    this.selectedDaySchedule,
    this.groupedTodaySchedule,
  );
}
