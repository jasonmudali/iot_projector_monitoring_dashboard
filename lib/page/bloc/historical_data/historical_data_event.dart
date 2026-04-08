part of 'historical_data_bloc.dart';

@immutable
sealed class HistoricalDataEvent {}

class FetchHistoricalData extends HistoricalDataEvent {
  final String classroom;
  final String duration;

  FetchHistoricalData({required this.classroom, required this.duration});
}
