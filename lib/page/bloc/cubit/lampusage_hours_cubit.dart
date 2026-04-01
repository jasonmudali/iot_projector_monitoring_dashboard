import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:skripsi_iot_projector/model/lampusage_hours_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'lampusage_hours_state.dart';

class LampusageHoursCubit extends Cubit<LampusageHoursState> {
  final supabase = Supabase.instance.client;
  Map<String, double> hoursData = {};
  List<LampUsageHoursModel> lampUsageList = [];

  LampusageHoursCubit() : super(LampusageHoursInitial());

  Future<void> fetchLampUsageHours() async {
    try {
      final result = await supabase.from('tbl_lampusage').select();

      if (result.isNotEmpty) {
        lampUsageList = (result as List)
            .map((json) => LampUsageHoursModel.fromJson(json))
            .toList();
        print(
          "Fetched lamp usage hours: ${lampUsageList[0].classroom}, ${lampUsageList[0].hours}",
        );
      }

      emit(LampUsageHoursLoaded(lampUsageList));
    } catch (e) {
      print('Error fetching lamp usage hours: $e');
    }
  }
}
