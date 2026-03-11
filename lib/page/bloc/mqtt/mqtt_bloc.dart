import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meta/meta.dart';
import 'package:skripsi_iot_projector/model/projector_model.dart';
import 'package:skripsi_iot_projector/repository/mqtt_repository.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final MqttRepository mqttRepository;

  MqttBloc(this.mqttRepository)
    : super(
        ProjectorState(
          projectorStats: {
            "HD03": ProjectorModel(id: "HD03"),
            "HD04": ProjectorModel(id: "HD04"),
            "L1D": ProjectorModel(id: "L1D"),
          },
          temperatureData: {},
          humidityData: {},
          timeData: {},
          xValue: {},
        ),
      ) {
    on<StartListening>((event, emit) {
      mqttRepository.projectorStream.listen((data) {
        add(NewMqttData(data));
      });
    });

    on<NewMqttData>((event, emit) {
      final currentState = state;
      if (currentState is ProjectorState) {
        final currentStats = Map<String, ProjectorModel>.from(
          currentState.projectorStats,
        );

        final updatedModel = ProjectorModel.fromJson(event.data);

        currentStats[updatedModel.id] = updatedModel;

        final roomId = updatedModel.id;

        final updatedTempList = List<FlSpot>.from(
          currentState.temperatureData[roomId] ?? [],
        );
        final updatedHumidList = List<FlSpot>.from(
          currentState.humidityData[roomId] ?? [],
        );
        final updatedTimeList = List<DateTime>.from(
          currentState.timeData[roomId] ?? [],
        );
        final currentXValue = currentState.xValue[roomId] ?? 0;

        updatedTempList.add(
          FlSpot(currentXValue.toDouble(), updatedModel.temperature),
        );
        updatedHumidList.add(
          FlSpot(currentXValue.toDouble(), updatedModel.humidity),
        );
        updatedTimeList.add(DateTime.now());
        // if (updatedTempList.length > 20) {
        //   updatedTempList.removeAt(0);
        //   updatedHumidList.removeAt(0);
        // }

        emit(
          ProjectorState(
            projectorStats: currentStats,
            temperatureData: {
              ...currentState.temperatureData,
              roomId: updatedTempList,
            },
            humidityData: {
              ...currentState.humidityData,
              roomId: updatedHumidList,
            },
            timeData: {...currentState.timeData, roomId: updatedTimeList},
            xValue: {...currentState.xValue, roomId: currentXValue + 1},
          ),
        );
      }
    });
  }
}
