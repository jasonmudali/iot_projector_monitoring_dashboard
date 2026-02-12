import 'package:flutter/material.dart';
import 'package:skripsi_iot_projector/page/bloc/mqtt/mqtt_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Projector Monitoring Dashboard',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<MqttBloc, MqttState>(
            builder: (context, state) {
              final data = (state as ProjectorState).projectorStats;
              return GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
                children: [
                  _buildProjectorCard(
                    context,
                    roomName: "HD3",
                    temp: data["HD03"]?.temperature ?? 0.0,
                    hours: data["HD03"]?.lampHours.toStringAsFixed(0) ?? "0",
                    humidity: data["HD03"]?.humidity ?? 0.0,
                    isOn: data["HD03"]?.status == "ON" ? true : false,
                    cardColor: cardColor,
                  ),
                  // _buildProjectorCard(
                  //   context,
                  //   roomName: "HD4",
                  //   temp: data["HD4"]?.temperature ?? 0.0,
                  //   hours: data["HD4"]?.lampHours.toStringAsFixed(0) ?? "0",
                  //   humidity: data["HD4"]?.humidity ?? 0.0,
                  //   isOn: data["HD4"]?.projector == "ON" ? true : false,
                  //   cardColor: cardColor,
                  // ),
                  // _buildProjectorCard(
                  //   context,
                  //   roomName: "L1D",
                  //   temp: data["L1D"]?.temperature ?? 0.0,
                  //   hours: data["L1D"]?.lampHours.toStringAsFixed(0) ?? "0",
                  //   humidity: data["L1D"]?.humidity ?? 0.0,
                  //   isOn: data["L1D"]?.projector == "ON" ? true : false,
                  //   cardColor: cardColor,
                  // ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildProjectorCard(
  BuildContext context, {
  required String roomName,
  required double temp,
  required double humidity,
  required String hours,
  required bool isOn,
  required Color cardColor,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isOn
            ? Colors.green.withOpacity(0.5)
            : Theme.of(context).dividerColor,
        width: 2,
      ),
      boxShadow: isOn
          ? [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ]
          : Theme.of(context).brightness == Brightness.dark
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Nama Kelas & Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              roomName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.circle,
              color: isOn ? Colors.green : Colors.red,
              size: 12,
            ),
          ],
        ),
        Divider(height: 30, color: Theme.of(context).dividerColor),
        // Body: Data Utama
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoRow(Icons.thermostat, "Temp", "${temp}°C"),
              _infoRow(Icons.timer, "Usage", hours),
              _infoRow(Icons.auto_graph, "Humidity", "${humidity}%"),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.blueAccent),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
