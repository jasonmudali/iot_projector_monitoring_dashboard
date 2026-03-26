import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/model/schedule_model.dart';
import 'package:skripsi_iot_projector/model/update_schedule_model.dart';
import 'package:skripsi_iot_projector/page/bloc/schedule/schedule_bloc.dart';
import 'package:skripsi_iot_projector/widgets/schedule_list_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:skripsi_iot_projector/page/detail_dashboard.dart';

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
    context.read<ScheduleBloc>().add(
      LoadScheduleEvent(selectedDate: _selectedDay),
    );
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
          final DateTime activeSelectedDay = (state is ScheduleLoaded)
              ? state.selectedDate
              : (state is SelectCalendarDateLoaded)
              ? state.selectedDate
              : (_selectedDay ?? _focusedDay);

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _scheduleCalendar(
                context,
                wholeSchedule: wholeSchedule,
                selectedDaySchedule: selectedDaySchedule,
                selectedDay: activeSelectedDay,
                focusedDay: activeSelectedDay,
              ),
              SizedBox(width: 24),
              Expanded(
                child: ScheduleListView(
                  scheduleForSelectedDay: selectedDaySchedule,
                  groupedSchedules: groupedTodaySchedule,
                  selectedDay: activeSelectedDay,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(24),
          color: theme.primaryColor.withOpacity(0.3),
          strokeWidth: 1.5,
          dashPattern: const [10, 6],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
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
              hoverColor: theme.primaryColor.withOpacity(0.05),
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 280,
                width: 480,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Upload Jadwal Kuliah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada jadwal. Klik untuk mengupload file jadwal',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.fileExcel,
                            size: 13,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '.xlsx only',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.fileExcel,
                size: 36,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'File Siap Diupload',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(file.size / 1024).toStringAsFixed(2)} KB',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '.xlsx',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      context.read<ScheduleBloc>().add(
                        ResetFileSelectionEvent(),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Batal",
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BlocBuilder<ScheduleBloc, ScheduleState>(
                    builder: (context, state) {
                      return ElevatedButton.icon(
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
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: (state is UploadScheduleLoading)
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined, size: 20),
                        label: Text(
                          (state is UploadScheduleLoading)
                              ? "Mengupload..."
                              : "Upload Jadwal",
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _scheduleCalendar(
    BuildContext context, {
    required List<ScheduleModel> wholeSchedule,
    required List<ScheduleModel> selectedDaySchedule,
    required DateTime selectedDay,
    required DateTime focusedDay,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 300,
      height: 385,
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
        focusedDay: focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          return wholeSchedule
              .where(
                (s) =>
                    DateFormat('yyyy-MM-dd').format(s.tanggal) ==
                    DateFormat('yyyy-MM-dd').format(day.toLocal()),
              )
              .toList();
        },
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          context.read<ScheduleBloc>().add(
            CalendarDateSelectedEvent(
              selectedDate: selectedDay,
              scheduleForSelectedDay: wholeSchedule
                  .where(
                    (s) =>
                        DateFormat('yyyy-MM-dd').format(s.tanggal) ==
                        DateFormat('yyyy-MM-dd').format(selectedDay),
                  )
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
