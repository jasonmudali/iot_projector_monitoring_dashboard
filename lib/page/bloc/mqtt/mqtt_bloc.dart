import 'package:bloc/bloc.dart';
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
            "HD4": ProjectorModel(id: "HD4"),
            "L1D": ProjectorModel(id: "L1D"),
          },
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

        emit(ProjectorState(projectorStats: currentStats));
      }
    });
  }
}
