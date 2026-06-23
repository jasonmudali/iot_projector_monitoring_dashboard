import 'package:flutter/material.dart';
import 'package:skripsi_iot_projector/model/lampusage_hours_model.dart';
import 'package:skripsi_iot_projector/page/bloc/cubit/lampusage_hours_cubit.dart';
import 'package:skripsi_iot_projector/page/bloc/mqtt/mqtt_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).canvasColor;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 600;

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: BlocBuilder<MqttBloc, MqttState>(
          buildWhen: (previous, current) => current is ProjectorState,
          builder: (context, state) {
            final data = (state as ProjectorState).projectorStats;
            return Padding(
              padding: isDesktop
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 20),
              child: Column(
                crossAxisAlignment: isDesktop
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Projector Monitoring Dashboard',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildClassCard(
                        context,
                        roomName: "HD03",
                        temp: data["HD03"]?.temperature ?? 0.0,
                        hours: "0",
                        humidity: data["HD03"]?.humidity ?? 0.0,
                        isOn: data["HD03"]?.status == "ON" ? true : false,
                        isHumanPresent: data["HD03"]?.presence ?? false,
                        cardColor: cardColor,
                      ),
                      _buildClassCard(
                        context,
                        roomName: "HD04",
                        temp: data["HD04"]?.temperature ?? 0.0,
                        hours: "0",
                        humidity: data["HD04"]?.humidity ?? 0.0,
                        isOn: data["HD04"]?.status == "ON" ? true : false,
                        isHumanPresent: data["HD04"]?.presence ?? false,
                        cardColor: cardColor,
                      ),
                      // _buildClassCard(
                      //   context,
                      //   roomName: "L1D",
                      //   temp: data["L1D"]?.temperature ?? 0.0,
                      //   hours: "0",
                      //   humidity: data["L1D"]?.humidity ?? 0.0,
                      //   isOn: data["L1D"]?.status == "ON" ? true : false,
                      //   isHumanPresent: data["L1D"]?.presence ?? false,
                      //   cardColor: cardColor,
                      // ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildClassCard(
  BuildContext context, {
  required String roomName,
  required double temp,
  required double humidity,
  required String hours,
  required bool isOn,
  required bool isHumanPresent,
  required Color cardColor,
}) {
  final double width = MediaQuery.of(context).size.width;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final statusColor = isOn ? Colors.green : Colors.grey;

  return InkWell(
    onTap: () {
      final lampState = context.read<LampusageHoursCubit>().state;
      int currentHours = 0;

      if (lampState is LampUsageHoursLoaded) {
        final projectorData = lampState.hoursData.firstWhere(
          (item) => item.classroom == roomName,
          orElse: () => LampUsageHoursModel(classroom: roomName, hours: 0),
        );
        currentHours = projectorData.hours;
      }

      context.push('/dashboard/detail/$roomName', extra: currentHours);
    },
    hoverColor: Theme.of(context).hoverColor,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    child: Ink(
      width: width < 600 ? 350 : 300,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOn ? statusColor : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Text(
                roomName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOn
                      ? statusColor.withOpacity(0.3)
                      : statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 7),
                    const SizedBox(width: 5),
                    Text(
                      isOn ? "ON" : "OFF",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoRow(
                  Icons.thermostat_rounded,
                  "Temp",
                  Text(
                    "${temp.toStringAsFixed(1)}°C",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Color.fromARGB(255, 255, 115, 0),
                ),
                _infoRow(
                  Icons.lightbulb_outline_rounded,
                  "Lamp",
                  Text("${hours}h"),
                  Colors.amber,
                  roomName,
                ),
                _infoRow(
                  Icons.water_drop_outlined,
                  "Humidity",
                  Text(
                    "${humidity.toStringAsFixed(0)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Colors.blueAccent,
                ),
                _infoRow(
                  Icons.person_outline_rounded,
                  "People",
                  isHumanPresent
                      ? Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.withOpacity(0.8),
                        )
                      : Icon(Icons.cancel, color: Colors.red.withOpacity(0.8)),
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _infoRow(
  IconData icon,
  String label,
  Widget value,
  Color color, [
  String? roomName,
]) {
  return Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const Spacer(),
      label == "Lamp"
          ? BlocBuilder<LampusageHoursCubit, LampusageHoursState>(
              builder: (context, state) {
                if (state is LampusageHoursInitial) {
                  return const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                } else if (state is LampUsageHoursLoaded) {
                  final projectorData = state.hoursData.firstWhere(
                    (item) => item.classroom == roomName,
                    orElse: () =>
                        LampUsageHoursModel(classroom: roomName!, hours: 0),
                  );
                  return Text(
                    '${projectorData.hours}h',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }
                return const Text('Loading...');
              },
            )
          : value,
    ],
  );
}
