import 'package:flutter/material.dart';
import 'package:skripsi_iot_projector/page/bloc/mqtt/mqtt_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skripsi_iot_projector/page/detail_dashboard.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 600;

    return Column(
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
        Expanded(
          child: SingleChildScrollView(
            child: BlocBuilder<MqttBloc, MqttState>(
              builder: (context, state) {
                final data = (state as ProjectorState).projectorStats;
                return Padding(
                  padding: isDesktop
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(right: 20),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildClassCard(
                        context,
                        roomName: "HD3",
                        temp: data["HD3"]?.temperature ?? 0.0,
                        hours: data["HD3"]?.lampHours.toStringAsFixed(0) ?? "0",
                        humidity: data["HD3"]?.humidity ?? 0.0,
                        isOn: data["HD3"]?.status == "ON" ? true : false,
                        cardColor: cardColor,
                      ),
                      _buildClassCard(
                        context,
                        roomName: "HD4",
                        temp: data["HD4"]?.temperature ?? 0.0,
                        hours: data["HD4"]?.lampHours.toStringAsFixed(0) ?? "0",
                        humidity: data["HD4"]?.humidity ?? 0.0,
                        isOn: data["HD4"]?.status == "ON" ? true : false,
                        cardColor: cardColor,
                      ),
                      _buildClassCard(
                        context,
                        roomName: "L1D",
                        temp: data["L1D"]?.temperature ?? 0.0,
                        hours: data["L1D"]?.lampHours.toStringAsFixed(0) ?? "0",
                        humidity: data["L1D"]?.humidity ?? 0.0,
                        isOn: data["L1D"]?.status == "ON" ? true : false,
                        cardColor: cardColor,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
  required Color cardColor,
}) {
  final double width = MediaQuery.of(context).size.width;

  return InkWell(
    onTap: () {
      context.push('/dashboard/detail/$roomName');
    },
    hoverColor: Theme.of(context).hoverColor,
    splashColor: Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    child: Ink(
      width: width < 600 ? 350 : 300,
      height: 200,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
