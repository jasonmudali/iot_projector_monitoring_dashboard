import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/mqtt/mqtt_bloc.dart';

enum ChartMode { live, hour, day }

class DetailDashboard extends StatefulWidget {
  final String roomName;

  const DetailDashboard({super.key, required this.roomName});

  @override
  State<DetailDashboard> createState() => _DetailDashboardState();
}

class _DetailDashboardState extends State<DetailDashboard> {
  ChartMode selectedModeTemp = ChartMode.live;
  ChartMode selectedModeHumid = ChartMode.live;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;

    List<FlSpot> temperatureData = [];
    List<FlSpot> humidityData = [];
    int xValue = 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.roomName,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time Monitoring',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            BlocBuilder<MqttBloc, MqttState>(
              builder: (context, state) {
                final data = (state as ProjectorState).projectorStats;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildChartCard(
                      context,
                      icon: Icons.thermostat,
                      title: "Temperature",
                      value:
                          "${data[widget.roomName]?.temperature.toStringAsFixed(1) ?? "0"}",
                      unit: "°C",
                      lineArrowColor: Colors.orange,
                      cardColor: cardColor,
                      chartData: state.temperatureData[widget.roomName] ?? [],
                      timeData: state.timeData[widget.roomName] ?? [],
                      selectedMode: selectedModeTemp,
                      onModeChanged: (newMode) {
                        setState(() => selectedModeTemp = newMode);
                      },
                    ),
                    _buildChartCard(
                      context,
                      icon: Icons.water_drop,
                      title: "Humidity",
                      value:
                          "${data[widget.roomName]?.humidity.toStringAsFixed(1) ?? "0"}",
                      unit: "%",
                      lineArrowColor: Colors.blue,
                      cardColor: cardColor,
                      chartData: state.humidityData[widget.roomName] ?? [],
                      timeData: state.timeData[widget.roomName] ?? [],
                      selectedMode: selectedModeHumid,
                      onModeChanged: (newMode) {
                        setState(() => selectedModeHumid = newMode);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color lineArrowColor,
    required Color cardColor,
    required List<FlSpot> chartData,
    required List<DateTime> timeData,
    required ChartMode selectedMode,
    required Function(ChartMode) onModeChanged,
  }) {
    double dynamicInterval = 1.0;
    if (chartData.length > 10) {
      dynamicInterval = (chartData.length / 6).floorToDouble();
      if (dynamicInterval < 1) dynamicInterval = 1;
    }

    double minX = chartData.isNotEmpty ? chartData.first.x : 0;
    double maxX = chartData.isNotEmpty ? chartData.last.x : 10;

    if (maxX - minX < 10) maxX = minX + 10;

    return Container(
      width: 400,
      height: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey
                  : Colors.black.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lineArrowColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: lineArrowColor),
              ),
              SizedBox(
                height: 35,
                child: SegmentedButton<ChartMode>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: lineArrowColor,
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  segments: const [
                    ButtonSegment(value: ChartMode.live, label: Text('Live')),
                    ButtonSegment(value: ChartMode.hour, label: Text('1H')),
                    ButtonSegment(value: ChartMode.day, label: Text('24H')),
                  ],
                  selected: {selectedMode},
                  onSelectionChanged: (Set<ChartMode> newSelection) {
                    onModeChanged(newSelection.first);
                    print(newSelection.first);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            value + " " + unit,
            style: TextStyle(
              fontSize: 26,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 80,

                minX: minX,
                maxX: maxX,

                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      interval: 20,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      // showTitles: true,
                      reservedSize: 30,
                      // interval: dynamicInterval,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: lineArrowColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineArrowColor.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: Colors.grey.withOpacity(
                                0.5,
                              ), // Subtle color
                              strokeWidth: 2.0,
                              dashArray: [3, 3],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 5,
                                    color: lineArrowColor,
                                  ),
                            ),
                          );
                        }).toList();
                      },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.blueGrey.withOpacity(0.9),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();

                        final int listIndex = touchedSpots.first.spotIndex;

                        final times = timeData;
                        String timeStr = "---";

                        if (listIndex >= 0 && listIndex < times.length) {
                          final t = times[listIndex];
                          // Format: 14:05:01
                          timeStr =
                              "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}";
                        }
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}$unit\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Time: $timeStr',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
