part of 'lampusage_hours_cubit.dart';

@immutable
sealed class LampusageHoursState {}

final class LampusageHoursInitial extends LampusageHoursState {}

final class LampUsageHoursLoaded extends LampusageHoursState {
  final List<LampUsageHoursModel> hoursData;

  LampUsageHoursLoaded(this.hoursData);
}
