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

// displaying schedule to calendar
final class ScheduleLoaded extends ScheduleState {
  List<ScheduleModel> wholeSchedule;
  final List<ScheduleModel> selectedDaySchedule;

  ScheduleLoaded(this.wholeSchedule, this.selectedDaySchedule);
}

// get schedule data from database
final class ScheduleLoading extends ScheduleState {}

final class ScheduleLoadedEmpty extends ScheduleState {}

final class ScheduleFailure extends ScheduleState {
  final String error;
  ScheduleFailure(this.error);
}

final class SelectCalendarDateLoading extends ScheduleState {
  final List<ScheduleModel> wholeSchedule;
  SelectCalendarDateLoading(this.wholeSchedule);
}

final class SelectCalendarDateLoaded extends ScheduleState {
  final List<ScheduleModel> wholeSchedule;
  final List<ScheduleModel> selectedDaySchedule;
  SelectCalendarDateLoaded(this.wholeSchedule, this.selectedDaySchedule);
}
