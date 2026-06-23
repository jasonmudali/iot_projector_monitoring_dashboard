import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/historical_data/historical_data_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/mqtt/mqtt_bloc.dart';

enum ChartMode { live, hour, day }

class DetailDashboard extends StatefulWidget {
  final String roomName;
  final int lampHours;

  const DetailDashboard({
    super.key,
    required this.roomName,
    required this.lampHours,
  });

  @override
  State<DetailDashboard> createState() => _DetailDashboardState();
}

class _DetailDashboardState extends State<DetailDashboard>
    with TickerProviderStateMixin {
  ChartMode selectedMode = ChartMode.live;
  late AnimationController _statusAnimController;

  @override
  void initState() {
    super.initState();
    _statusAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MqttBloc>().add(
          ChangeModeEvent(widget.roomName, ChartMode.live.name),
        );
      }
    });
  }

  @override
  void dispose() {
    _statusAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).canvasColor;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Real-time Monitoring',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  BlocBuilder<MqttBloc, MqttState>(
                    buildWhen: (previous, current) => current is ProjectorState,
                    builder: (context, state) {
                      final data = (state as ProjectorState).projectorStats;
                      final isOn = data[widget.roomName]?.status == "ON"
                          ? true
                          : false;
                      final statusColor = isOn
                          ? Colors.green
                          : Colors.redAccent;

                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _statusAnimController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: Tween<double>(begin: 0.6, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _statusAnimController,
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                child: Icon(
                                  Icons.circle,
                                  color: statusColor,
                                  size: 8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOn ? "ON" : "OFF",
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Mode selection dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  // horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Data View Mode: ',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SegmentedButton<ChartMode>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.comfortable,
                              selectedForegroundColor: Theme.of(
                                context,
                              ).focusColor,
                              selectedBackgroundColor: Theme.of(
                                context,
                              ).primaryColor,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: Colors.transparent,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            segments: const [
                              ButtonSegment(
                                value: ChartMode.live,
                                label: Text('Live'),
                              ),
                              ButtonSegment(
                                value: ChartMode.hour,
                                label: Text('1H'),
                              ),
                              ButtonSegment(
                                value: ChartMode.day,
                                label: Text('24H'),
                              ),
                            ],
                            selected: {selectedMode},
                            onSelectionChanged: (Set<ChartMode> newSelection) {
                              setState(() => selectedMode = newSelection.first);
                              context.read<MqttBloc>().add(
                                ChangeModeEvent(
                                  widget.roomName,
                                  newSelection.first.name,
                                ),
                              );
                              if (newSelection.first != ChartMode.live) {
                                context.read<HistoricalDataBloc>().add(
                                  FetchHistoricalData(
                                    classroom: widget.roomName,
                                    duration: newSelection.first.name,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).focusColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return BlocConsumer<MqttBloc, MqttState>(
                              listenWhen: (previous, current) =>
                                  previous is CalibratingLuxValueState &&
                                  current is ProjectorState,
                              listener: (context, state) {
                                Navigator.of(context).pop();
                              },
                              builder: (context, state) {
                                final isLoading =
                                    state is CalibratingLuxValueState;
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Text("Calibrate Brightness"),
                                  content: const Text(
                                    "Are you sure want to calibrate the classroom brightness?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => Navigator.of(context).pop(),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              context.read<MqttBloc>().add(
                                                CalibrateLuxValueEvent(),
                                              );
                                            },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text("Calibrate classroom brightness"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BlocListener<HistoricalDataBloc, HistoricalDataState>(
                listener: (context, histState) {
                  if (histState is HistoricalDataLoaded) {
                    final duration = selectedMode == ChartMode.hour
                        ? "hour"
                        : "day";
                    print(
                      "DEBUG: HistoricalDataLoaded received. Duration: $duration",
                    );
                    context.read<MqttBloc>().add(
                      SetHistoricalDataEvent(
                        roomId: widget.roomName,
                        duration: duration,
                        tempData: histState.tempData,
                        humidData: histState.humidData,
                        timeData: histState.timeData,
                      ),
                    );
                  }
                },
                child: BlocBuilder<HistoricalDataBloc, HistoricalDataState>(
                  builder: (context, histState) {
                    return BlocBuilder<MqttBloc, MqttState>(
                      buildWhen: (previous, current) =>
                          current is ProjectorState,
                      builder: (context, state) {
                        final data = (state as ProjectorState).projectorStats;
                        final isLoading =
                            histState is HistoricalDataLoading &&
                            selectedMode != ChartMode.live;

                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            if (isLoading)
                              _buildLoadingChartCard(
                                context,
                                title: "Temperature",
                                lineArrowColor: Colors.orange,
                                cardColor: cardColor,
                              )
                            else
                              _buildChartCard(
                                context,
                                icon: Icons.thermostat,
                                title: "Temperature",
                                value:
                                    "${data[widget.roomName]?.temperature.toStringAsFixed(1) ?? "0"}",
                                unit: "°C",
                                lineArrowColor: Colors.orange,
                                cardColor: cardColor,
                                chartData:
                                    state.getDisplayTemperatureData(
                                      widget.roomName,
                                    ) ??
                                    [],
                                timeData:
                                    state.getDisplayTimeData(widget.roomName) ??
                                    [],
                                isLive: selectedMode == ChartMode.live,
                                averageValue: state.getAverageTemperatureValue(
                                  widget.roomName,
                                ),
                              ),
                            if (isLoading)
                              _buildLoadingChartCard(
                                context,
                                title: "Humidity",
                                lineArrowColor: Colors.blue,
                                cardColor: cardColor,
                              )
                            else
                              _buildChartCard(
                                context,
                                icon: Icons.water_drop,
                                title: "Humidity",
                                value:
                                    "${data[widget.roomName]?.humidity.toStringAsFixed(1) ?? "0"}",
                                unit: "%",
                                lineArrowColor: Colors.blue,
                                cardColor: cardColor,
                                chartData:
                                    state.getDisplayHumidityData(
                                      widget.roomName,
                                    ) ??
                                    [],
                                timeData:
                                    state.getDisplayTimeData(widget.roomName) ??
                                    [],
                                isLive: selectedMode == ChartMode.live,
                                averageValue: state.getAverageHumidityValue(
                                  widget.roomName,
                                ),
                              ),
                            Container(
                              width: 400,
                              height: 330,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lamp Usage",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey
                                          : Colors.black.withOpacity(0.8),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: PieChart(
                                      PieChartData(
                                        startDegreeOffset: 270,
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 50,
                                        sections: [
                                          PieChartSectionData(
                                            value: widget.lampHours.toDouble(),
                                            color: Colors.blue,
                                            radius: 20,
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            value: (5000 - widget.lampHours)
                                                .toDouble(),
                                            color: Colors.grey.withOpacity(0.2),
                                            radius: 20,
                                            showTitle: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Colors.blue,
                                            size: 10,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Used: ${widget.lampHours}h",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 20),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Colors.grey.withOpacity(0.2),
                                            size: 10,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Available: ${(5000 - widget.lampHours)}h",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChartCard(
    BuildContext context, {
    required String title,
    required Color lineArrowColor,
    required Color cardColor,
  }) {
    return Container(
      width: 400,
      height: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(lineArrowColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading historical data...',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    required bool isLive,
    double? averageValue,
  }) {
    double dynamicInterval = 1.0;
    if (chartData.length > 10) {
      dynamicInterval = (chartData.length / 6).floorToDouble();
      if (dynamicInterval < 1) dynamicInterval = 1;
    }

    double minX = chartData.isNotEmpty ? chartData.first.x : 0;
    double maxX = chartData.isNotEmpty ? chartData.last.x : 10;

    if (double.parse(value) < 0.0) {
      value = "N/A";
    }

    if (maxX - minX < 10) maxX = minX + 10;

    return Container(
      width: 400,
      height: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lineArrowColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: lineArrowColor),
          ),
          SizedBox(height: 14),
          isLive
              ? Text(
                  value + " " + unit,
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  "Average: " + averageValue!.toStringAsFixed(1) + " " + unit,
                  style: TextStyle(
                    fontSize: 18,
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
                    sideTitles: SideTitles(reservedSize: 30),
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
                              color: Colors.grey.withOpacity(0.5),
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
