import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/model/schedule_model.dart';
import 'package:skripsi_iot_projector/page/bloc/schedule/schedule_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScheduleListView extends StatelessWidget {
  List<ScheduleModel> scheduleForSelectedDay;
  Map<String, List<ScheduleModel>> groupedSchedules;
  DateTime? selectedDay;

  ScheduleListView({
    super.key,
    required this.scheduleForSelectedDay,
    required this.groupedSchedules,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
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
            DateFormat('d MMMM yyyy').format(selectedDay!),
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
                                          bool isHovered = false;

                                          String currentStart =
                                              schedule.startTime;
                                          String currentEnd = schedule.endTime;

                                          return StatefulBuilder(
                                            builder: (context, setElementState) {
                                              return MouseRegion(
                                                onEnter: (_) {
                                                  setElementState(() {
                                                    isHovered = true;
                                                  });
                                                },
                                                onExit: (_) {
                                                  setElementState(() {
                                                    isHovered = false;
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => context.push(
                                                          '/dashboard/detail/${schedule.classroom}',
                                                        ),
                                                        hoverColor: Theme.of(
                                                          context,
                                                        ).hoverColor,
                                                        splashColor:
                                                            Colors.transparent,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 12,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                          0.5,
                                                                        ),
                                                                width: 3,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      schedule
                                                                          .mataKuliah,
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            19,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          FontAwesomeIcons
                                                                              .locationDot,
                                                                          size:
                                                                              14,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              8,
                                                                        ),
                                                                        Text(
                                                                          schedule
                                                                              .classroom,
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.grey[400],
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              isHovered
                                                                  ? Row(
                                                                      children: [
                                                                        IconButton(
                                                                          icon: Icon(
                                                                            Icons.edit_outlined,
                                                                            color:
                                                                                Colors.grey[600],
                                                                            size:
                                                                                20,
                                                                          ),
                                                                          onPressed: () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder:
                                                                                  (
                                                                                    context,
                                                                                  ) => StatefulBuilder(
                                                                                    builder:
                                                                                        (
                                                                                          context,
                                                                                          setState,
                                                                                        ) {
                                                                                          return AlertDialog(
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(
                                                                                                20,
                                                                                              ),
                                                                                            ),
                                                                                            backgroundColor: theme.scaffoldBackgroundColor,
                                                                                            titlePadding: const EdgeInsets.fromLTRB(
                                                                                              24,
                                                                                              24,
                                                                                              24,
                                                                                              0,
                                                                                            ),
                                                                                            title: Row(
                                                                                              children: [
                                                                                                Icon(
                                                                                                  Icons.edit_calendar,
                                                                                                  color: theme.primaryColor,
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  width: 10,
                                                                                                ),
                                                                                                const Text(
                                                                                                  "Edit Jam Kuliah",
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 20,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            content: SizedBox(
                                                                                              width:
                                                                                                  MediaQuery.of(
                                                                                                    context,
                                                                                                  ).size.width *
                                                                                                  0.3,
                                                                                              child: SingleChildScrollView(
                                                                                                child: Column(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: double.infinity,
                                                                                                      padding: const EdgeInsets.all(
                                                                                                        16,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: theme.primaryColor.withOpacity(
                                                                                                          0.05,
                                                                                                        ),
                                                                                                        borderRadius: BorderRadius.circular(
                                                                                                          15,
                                                                                                        ),
                                                                                                        border: Border.all(
                                                                                                          color: theme.primaryColor.withOpacity(
                                                                                                            0.1,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            "MATA KULIAH",
                                                                                                            style: TextStyle(
                                                                                                              fontSize: 12,
                                                                                                              color: Colors.grey[600],
                                                                                                              letterSpacing: 1.2,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Text(
                                                                                                            schedule.mataKuliah,
                                                                                                            style: const TextStyle(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontSize: 16,
                                                                                                            ),
                                                                                                          ),
                                                                                                          const SizedBox(
                                                                                                            height: 8,
                                                                                                          ),
                                                                                                          Text(
                                                                                                            "RUANGAN",
                                                                                                            style: TextStyle(
                                                                                                              fontSize: 12,
                                                                                                              color: Colors.grey[600],
                                                                                                              letterSpacing: 1.2,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Text(
                                                                                                            schedule.classroom,
                                                                                                            style: const TextStyle(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontSize: 16,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                    const Padding(
                                                                                                      padding: EdgeInsets.symmetric(
                                                                                                        vertical: 20,
                                                                                                      ),
                                                                                                      child: Text(
                                                                                                        "Sesuaikan Waktu Kuliah:",
                                                                                                        style: TextStyle(
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                          fontSize: 16,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Row(
                                                                                                      children: [
                                                                                                        // Jam Mulai
                                                                                                        Expanded(
                                                                                                          child: InkWell(
                                                                                                            onTap: () async {
                                                                                                              final TimeOfDay? picked = await showTimePicker(
                                                                                                                context: context,
                                                                                                                initialTime: TimeOfDay(
                                                                                                                  hour: int.parse(
                                                                                                                    currentStart.split(
                                                                                                                      ":",
                                                                                                                    )[0],
                                                                                                                  ),
                                                                                                                  minute: int.parse(
                                                                                                                    currentStart.split(
                                                                                                                      ":",
                                                                                                                    )[1],
                                                                                                                  ),
                                                                                                                ),
                                                                                                                builder:
                                                                                                                    (
                                                                                                                      context,
                                                                                                                      child,
                                                                                                                    ) {
                                                                                                                      return Theme(
                                                                                                                        data: theme.copyWith(
                                                                                                                          colorScheme: theme.colorScheme.copyWith(
                                                                                                                            surface: theme.scaffoldBackgroundColor,
                                                                                                                            primary: theme.primaryColor,
                                                                                                                            onPrimary: theme.focusColor,
                                                                                                                          ),
                                                                                                                          textButtonTheme: TextButtonThemeData(
                                                                                                                            style: TextButton.styleFrom(
                                                                                                                              foregroundColor: theme.primaryColor,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          timePickerTheme: TimePickerThemeData(
                                                                                                                            confirmButtonStyle: ElevatedButton.styleFrom(
                                                                                                                              textStyle: TextStyle(
                                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                              ),
                                                                                                                              backgroundColor: theme.primaryColor,
                                                                                                                              foregroundColor: theme.focusColor,
                                                                                                                              elevation: 0,
                                                                                                                              shape: RoundedRectangleBorder(
                                                                                                                                borderRadius: BorderRadius.circular(
                                                                                                                                  12,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              padding: const EdgeInsets.symmetric(
                                                                                                                                vertical: 15,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            dialBackgroundColor: theme.primaryColor.withOpacity(
                                                                                                                              0.1,
                                                                                                                            ),
                                                                                                                            backgroundColor: theme.scaffoldBackgroundColor,
                                                                                                                            hourMinuteColor: WidgetStateColor.resolveWith(
                                                                                                                              (
                                                                                                                                states,
                                                                                                                              ) {
                                                                                                                                if (states.contains(
                                                                                                                                  WidgetState.selected,
                                                                                                                                )) {
                                                                                                                                  return theme.primaryColor.withOpacity(
                                                                                                                                    0.3,
                                                                                                                                  );
                                                                                                                                }
                                                                                                                                return theme.primaryColor.withOpacity(
                                                                                                                                  0.1,
                                                                                                                                );
                                                                                                                              },
                                                                                                                            ),
                                                                                                                            hourMinuteTextColor: theme.primaryColor,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        child: MediaQuery(
                                                                                                                          data:
                                                                                                                              MediaQuery.of(
                                                                                                                                context,
                                                                                                                              ).copyWith(
                                                                                                                                alwaysUse24HourFormat: true,
                                                                                                                              ),
                                                                                                                          child: child!,
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    },
                                                                                                              );
                                                                                                              if (picked !=
                                                                                                                  null) {
                                                                                                                setState(
                                                                                                                  () {
                                                                                                                    currentStart = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                                                                                                  },
                                                                                                                );
                                                                                                              }
                                                                                                            },
                                                                                                            child: Container(
                                                                                                              padding: const EdgeInsets.all(
                                                                                                                15,
                                                                                                              ),
                                                                                                              decoration: BoxDecoration(
                                                                                                                border: Border.all(
                                                                                                                  color: theme.primaryColor.withOpacity(
                                                                                                                    0.3,
                                                                                                                  ),
                                                                                                                ),
                                                                                                                borderRadius: BorderRadius.circular(
                                                                                                                  12,
                                                                                                                ),
                                                                                                              ),
                                                                                                              child: Column(
                                                                                                                children: [
                                                                                                                  const Text(
                                                                                                                    "Mulai",
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 12,
                                                                                                                      color: Colors.grey,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  const SizedBox(
                                                                                                                    height: 5,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    currentStart,
                                                                                                                    style: const TextStyle(
                                                                                                                      fontSize: 20,
                                                                                                                      fontWeight: FontWeight.bold,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        const SizedBox(
                                                                                                          width: 15,
                                                                                                        ),
                                                                                                        // Jam Selesai
                                                                                                        Expanded(
                                                                                                          child: InkWell(
                                                                                                            onTap: () async {
                                                                                                              final TimeOfDay? picked = await showTimePicker(
                                                                                                                context: context,
                                                                                                                initialTime: TimeOfDay(
                                                                                                                  hour: int.parse(
                                                                                                                    currentEnd.split(
                                                                                                                      ":",
                                                                                                                    )[0],
                                                                                                                  ),
                                                                                                                  minute: int.parse(
                                                                                                                    currentEnd.split(
                                                                                                                      ":",
                                                                                                                    )[1],
                                                                                                                  ),
                                                                                                                ),
                                                                                                                builder:
                                                                                                                    (
                                                                                                                      context,
                                                                                                                      child,
                                                                                                                    ) {
                                                                                                                      return Theme(
                                                                                                                        data: theme.copyWith(
                                                                                                                          colorScheme: theme.colorScheme.copyWith(
                                                                                                                            surface: theme.scaffoldBackgroundColor,
                                                                                                                            primary: theme.primaryColor,
                                                                                                                            onPrimary: theme.focusColor,
                                                                                                                          ),
                                                                                                                          textButtonTheme: TextButtonThemeData(
                                                                                                                            style: TextButton.styleFrom(
                                                                                                                              foregroundColor: theme.primaryColor,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          timePickerTheme: TimePickerThemeData(
                                                                                                                            confirmButtonStyle: ElevatedButton.styleFrom(
                                                                                                                              textStyle: TextStyle(
                                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                              ),
                                                                                                                              backgroundColor: theme.primaryColor,
                                                                                                                              foregroundColor: theme.focusColor,
                                                                                                                              elevation: 0,
                                                                                                                              shape: RoundedRectangleBorder(
                                                                                                                                borderRadius: BorderRadius.circular(
                                                                                                                                  12,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              padding: const EdgeInsets.symmetric(
                                                                                                                                vertical: 15,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            dialBackgroundColor: theme.primaryColor.withOpacity(
                                                                                                                              0.1,
                                                                                                                            ),
                                                                                                                            backgroundColor: theme.scaffoldBackgroundColor,
                                                                                                                            hourMinuteColor: WidgetStateColor.resolveWith(
                                                                                                                              (
                                                                                                                                states,
                                                                                                                              ) {
                                                                                                                                if (states.contains(
                                                                                                                                  WidgetState.selected,
                                                                                                                                )) {
                                                                                                                                  return theme.primaryColor.withOpacity(
                                                                                                                                    0.3,
                                                                                                                                  );
                                                                                                                                }
                                                                                                                                return theme.primaryColor.withOpacity(
                                                                                                                                  0.1,
                                                                                                                                );
                                                                                                                              },
                                                                                                                            ),
                                                                                                                            hourMinuteTextColor: theme.primaryColor,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        child: MediaQuery(
                                                                                                                          data:
                                                                                                                              MediaQuery.of(
                                                                                                                                context,
                                                                                                                              ).copyWith(
                                                                                                                                alwaysUse24HourFormat: true,
                                                                                                                              ),
                                                                                                                          child: child!,
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    },
                                                                                                              );
                                                                                                              if (picked !=
                                                                                                                  null) {
                                                                                                                setState(
                                                                                                                  () {
                                                                                                                    currentEnd = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                                                                                                  },
                                                                                                                );
                                                                                                              }
                                                                                                            },
                                                                                                            child: Container(
                                                                                                              padding: const EdgeInsets.all(
                                                                                                                15,
                                                                                                              ),
                                                                                                              decoration: BoxDecoration(
                                                                                                                border: Border.all(
                                                                                                                  color: theme.primaryColor.withOpacity(
                                                                                                                    0.3,
                                                                                                                  ),
                                                                                                                ),
                                                                                                                borderRadius: BorderRadius.circular(
                                                                                                                  12,
                                                                                                                ),
                                                                                                              ),
                                                                                                              child: Column(
                                                                                                                children: [
                                                                                                                  const Text(
                                                                                                                    "Selesai",
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 12,
                                                                                                                      color: Colors.grey,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  const SizedBox(
                                                                                                                    height: 5,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    currentEnd,
                                                                                                                    style: const TextStyle(
                                                                                                                      fontSize: 20,
                                                                                                                      fontWeight: FontWeight.bold,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            actionsPadding: const EdgeInsets.fromLTRB(
                                                                                              16,
                                                                                              0,
                                                                                              16,
                                                                                              16,
                                                                                            ),
                                                                                            actions: [
                                                                                              SizedBox(
                                                                                                width: double.infinity,
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      child: TextButton(
                                                                                                        onPressed: () => Navigator.pop(
                                                                                                          context,
                                                                                                        ),
                                                                                                        child: Text(
                                                                                                          "Batal",
                                                                                                          style: TextStyle(
                                                                                                            color: theme.primaryColor,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(
                                                                                                      width: 10,
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      // flex: 2,
                                                                                                      child: ElevatedButton(
                                                                                                        style: ElevatedButton.styleFrom(
                                                                                                          backgroundColor: theme.primaryColor,
                                                                                                          foregroundColor: Colors.white,
                                                                                                          elevation: 0,
                                                                                                          shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(
                                                                                                              12,
                                                                                                            ),
                                                                                                          ),
                                                                                                          padding: const EdgeInsets.symmetric(
                                                                                                            vertical: 15,
                                                                                                          ),
                                                                                                        ),
                                                                                                        onPressed: () {
                                                                                                          context
                                                                                                              .read<
                                                                                                                ScheduleBloc
                                                                                                              >()
                                                                                                              .add(
                                                                                                                UpdateScheduleEvent(
                                                                                                                  schedule: schedule,
                                                                                                                  updatedScheduleDate: selectedDay!,
                                                                                                                  newStartTime: currentStart,
                                                                                                                  newEndTime: currentEnd,
                                                                                                                ),
                                                                                                              );
                                                                                                          Navigator.pop(
                                                                                                            context,
                                                                                                          );
                                                                                                        },
                                                                                                        child: Text(
                                                                                                          "Simpan Jadwal",
                                                                                                          style: TextStyle(
                                                                                                            color: theme.focusColor,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        },
                                                                                  ),
                                                                            );
                                                                          },
                                                                        ),
                                                                        IconButton(
                                                                          icon: const Icon(
                                                                            Icons.delete_outline,
                                                                            color:
                                                                                Colors.redAccent,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                          onPressed: () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder:
                                                                                  (
                                                                                    context,
                                                                                  ) => AlertDialog(
                                                                                    title: const Text(
                                                                                      "Hapus Jadwal?",
                                                                                    ),
                                                                                    content: Text(
                                                                                      "Apakah Anda yakin ingin menghapus jadwal ${schedule.mataKuliah}? Tindakan ini dilakukan jika Dosen berhalangan hadir.",
                                                                                    ),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                        onPressed: () => Navigator.pop(
                                                                                          context,
                                                                                        ),
                                                                                        style: TextButton.styleFrom(
                                                                                          foregroundColor: Colors.black,
                                                                                        ),
                                                                                        child: const Text(
                                                                                          "Batal",
                                                                                        ),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          // BlocProvider.of<ScheduleBloc>(context).add(DeleteScheduleEvent(schedule.id));
                                                                                          Navigator.pop(
                                                                                            context,
                                                                                          );
                                                                                        },
                                                                                        style: TextButton.styleFrom(
                                                                                          foregroundColor: Colors.red,
                                                                                        ),
                                                                                        child: const Text(
                                                                                          "Hapus",
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
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
}
