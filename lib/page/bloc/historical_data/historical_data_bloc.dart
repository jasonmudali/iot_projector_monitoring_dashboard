import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skripsi_iot_projector/model/historical_projector_data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'historical_data_event.dart';
part 'historical_data_state.dart';

class HistoricalDataBloc
    extends Bloc<HistoricalDataEvent, HistoricalDataState> {
  final supabase = Supabase.instance.client;

  HistoricalDataBloc() : super(HistoricalDataInitial()) {
    on<HistoricalDataEvent>((event, emit) {});

    on<FetchHistoricalData>((event, emit) async {
      emit(HistoricalDataLoading());

      try {
        List<FlSpot> tempData = [];
        List<FlSpot> humidData = [];
        List<DateTime> timeData = [];

        if (event.duration == "hour") {
          final result = await supabase
              .from('tbl_dataprojector')
              .select()
              .eq('classroom', event.classroom)
              .order('id', ascending: false)
              .limit(12);

          final sortedResult = result.reversed.toList();

          print("Fetched historical data: $result");

          if (sortedResult.isNotEmpty) {
            List<HistoricalProjectorDataModel> historicalData =
                (sortedResult as List)
                    .map((item) => HistoricalProjectorDataModel.fromJson(item))
                    .toList();

            for (int i = 0; i < historicalData.length; i++) {
              final data = historicalData[i];
              tempData.add(FlSpot(i.toDouble(), data.temperature));
              humidData.add(FlSpot(i.toDouble(), data.humidity));
              timeData.add(data.createdAt);
            }
          }
        } else {
          final result = await supabase
              .from('tbl_dataprojector')
              .select()
              .eq('classroom', event.classroom)
              .order('id', ascending: false)
              .limit(288);

          final sortedResult = result.reversed.toList();

          if (sortedResult.isNotEmpty) {
            List<HistoricalProjectorDataModel> historicalData =
                (sortedResult as List)
                    .map((item) => HistoricalProjectorDataModel.fromJson(item))
                    .toList();

            for (int i = 0; i < historicalData.length; i++) {
              final data = historicalData[i];
              tempData.add(FlSpot(i.toDouble(), data.temperature));
              humidData.add(FlSpot(i.toDouble(), data.humidity));
              timeData.add(data.createdAt);
            }
          }
        }

        emit(HistoricalDataLoaded(tempData, humidData, timeData));
      } catch (e) {
        emit(HistoricalDataInitial());
      }
    });
  }
}
