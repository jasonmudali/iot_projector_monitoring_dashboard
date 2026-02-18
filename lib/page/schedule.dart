import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/model/schedule_model.dart';
import 'package:skripsi_iot_projector/page/bloc/schedule/schedule_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<ScheduleBloc>().add(LoadScheduleEvent());
  }

  String _getHariName(int weekday) {
    const days = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
    };
    return days[weekday] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ScheduleInitial) {
          return _uploadFileWidget(context);
        } else if (state is ScheduleFileSelected ||
            state is UploadScheduleLoading) {
          final file = (state is ScheduleFileSelected)
              ? state.file
              : (state as UploadScheduleLoading).file;
          return _previewFileWidget(context, file);
        } else if (state is ScheduleLoaded ||
            state is SelectCalendarDateLoaded ||
            state is SelectCalendarDateLoading) {
          final List<ScheduleModel> wholeSchedule = (state is ScheduleLoaded)
              ? state.wholeSchedule
              : (state is SelectCalendarDateLoaded)
              ? state.wholeSchedule
              : (state as SelectCalendarDateLoading).wholeSchedule;
          final List<ScheduleModel> selectedDaySchedule =
              (state is ScheduleLoaded)
              ? state.selectedDaySchedule
              : (state is SelectCalendarDateLoaded)
              ? state.selectedDaySchedule
              : [];
          final Map<String, List<ScheduleModel>> groupedTodaySchedule =
              (state is ScheduleLoaded)
              ? state.groupedTodaySchedule
              : (state is SelectCalendarDateLoaded)
              ? state.groupedTodaySchedule
              : {};

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _scheduleCalendar(
                context,
                wholeSchedule: wholeSchedule,
                selectedDaySchedule: selectedDaySchedule,
              ),
              SizedBox(width: 24),
              Expanded(
                child: _scheduleListView(
                  context,
                  scheduleForSelectedDay: selectedDaySchedule,
                  groupedSchedules: groupedTodaySchedule,
                ),
              ),
            ],
          );
        } else if (state is ScheduleFailure) {
          return Center(
            child: Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _uploadFileWidget(BuildContext context) {
    return Center(
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(20),
          color: Theme.of(context).primaryColor.withOpacity(0.6),
          strokeWidth: 1,
          dashPattern: const [8, 4],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['xlsx'],
              );

              if (result != null) {
                context.read<ScheduleBloc>().add(
                  PickScheduleFileEvent(result.files.first),
                );
              }
            },
            splashColor: Colors.transparent,
            hoverColor: Colors.grey.withOpacity(0.3),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 250,
              width: 500,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada jadwal. Klik untuk mengupload file jadwal',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '.xlsx only',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewFileWidget(BuildContext context, PlatformFile file) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.fileExcel,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(file.size / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<ScheduleBloc>().add(
                        ResetFileSelectionEvent(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BlocBuilder<ScheduleBloc, ScheduleState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          (state is UploadScheduleLoading)
                              ? null
                              : context.read<ScheduleBloc>().add(
                                  UploadScheduleEvent(file),
                                );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: (state is UploadScheduleLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Upload Jadwal",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleListView(
    BuildContext context, {
    required List<ScheduleModel> scheduleForSelectedDay,
    required Map<String, List<ScheduleModel>> groupedSchedules,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.canvasColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            DateFormat('d MMMM yyyy').format(_selectedDay!),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is SelectCalendarDateLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return scheduleForSelectedDay.isEmpty
                      ? const Center(
                          child: Text("Tidak ada jadwal untuk hari ini"),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: groupedSchedules.keys.length,
                          itemBuilder: (context, index) {
                            String timeKey = groupedSchedules.keys.elementAt(
                              index,
                            );

                            List<ScheduleModel> classesAtThisTime =
                                groupedSchedules[timeKey]!;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          timeKey,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                        Container(
                                          width: 2,
                                          height: 20,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        Text(
                                          classesAtThisTime.first.endTime,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Column(
                                      children: [
                                        ...classesAtThisTime.map((schedule) {
                                          return Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.5),
                                                      width: 3,
                                                    ),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      schedule.mataKuliah,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          FontAwesomeIcons
                                                              .locationDot,
                                                          size: 14,
                                                          color: Colors.grey,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          schedule.classroom,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[400],
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 8.0,
                                          ),
                                          child: Divider(
                                            color: Theme.of(
                                              context,
                                            ).dividerColor.withOpacity(0.1),
                                            indent: 16,
                                            endIndent: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _scheduleCalendar(
    BuildContext context, {
    required List<ScheduleModel> wholeSchedule,
    required List<ScheduleModel> selectedDaySchedule,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 300,
      height: 380,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        rowHeight: 45,
        sixWeekMonthsEnforced: false,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          String currentHari = _getHariName(day.weekday);
          return wholeSchedule.where((s) => s.hari == currentHari).toList();
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          context.read<ScheduleBloc>().add(
            CalendarDateSelectedEvent(
              selectedDay: _getHariName(selectedDay.weekday),
              scheduleForSelectedDay: wholeSchedule
                  .where((s) => s.hari == _getHariName(selectedDay.weekday))
                  .toList(),
              wholeSchedule: wholeSchedule,
            ),
          );
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: theme.primaryColor),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: theme.primaryColor,
          ),
        ),
        calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(fontSize: 12),
          todayDecoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            fontSize: 12,
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          selectedTextStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
          ),
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
