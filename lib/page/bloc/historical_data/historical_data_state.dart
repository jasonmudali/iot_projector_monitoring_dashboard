part of 'historical_data_bloc.dart';

@immutable
sealed class HistoricalDataState {}

final class HistoricalDataInitial extends HistoricalDataState {}

class HistoricalDataLoading extends HistoricalDataState {}

class HistoricalDataLoaded extends HistoricalDataState {
  final List<FlSpot> tempData;
  final List<FlSpot> humidData;
  final List<DateTime> timeData;

  HistoricalDataLoaded(this.tempData, this.humidData, this.timeData);
}
