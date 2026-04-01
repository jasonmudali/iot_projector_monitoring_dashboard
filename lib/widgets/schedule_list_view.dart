import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/model/lampusage_hours_model.dart';
import 'package:skripsi_iot_projector/model/schedule_model.dart';
import 'package:skripsi_iot_projector/page/bloc/cubit/lampusage_hours_cubit.dart';
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.canvasColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('d MMMM yyyy').format(selectedDay!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 9.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                label: const Text(
                  "Replace Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: theme.scaffoldBackgroundColor,
                      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      title: Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, color: Colors.orange),
                          const SizedBox(width: 10),
                          const Text(
                            "Replace Schedule",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "Are you sure you want to delete all schedules and upload a new schedule? This action cannot be undone.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      actions: [
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: theme.primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<ScheduleBloc>().add(
                                      ReplaceScheduleEvent(),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Replace Schedule",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is SelectCalendarDateLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return scheduleForSelectedDay.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 48,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No classes scheduled for this day",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time column
                                  Container(
                                    width: 90,
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 3,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor
                                                .withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            timeKey,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 1.5,
                                          height: 14,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          color: isDark
                                              ? Colors.grey.withOpacity(0.7)
                                              : Colors.grey.withOpacity(0.4),
                                        ),
                                        Text(
                                          classesAtThisTime.first.endTime,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.grey[600]
                                                : Colors.grey[500],
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
                                          DateTime currentDate =
                                              schedule.tanggal;

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
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 6,
                                                          ),
                                                      child: Material(
                                                        color: isDark
                                                            ? Colors.white
                                                                  .withOpacity(
                                                                    0.02,
                                                                  )
                                                            : Colors.black
                                                                  .withOpacity(
                                                                    0.015,
                                                                  ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child: InkWell(
                                                          onTap: () {
                                                            final lampState =
                                                                context
                                                                    .read<
                                                                      LampusageHoursCubit
                                                                    >()
                                                                    .state;
                                                            int currentHours =
                                                                0;

                                                            if (lampState
                                                                is LampUsageHoursLoaded) {
                                                              final projectorData = lampState.hoursData.firstWhere(
                                                                (item) =>
                                                                    item.classroom ==
                                                                    schedule
                                                                        .classroom,
                                                                orElse: () =>
                                                                    LampUsageHoursModel(
                                                                      classroom:
                                                                          schedule
                                                                              .classroom,
                                                                      hours: 0,
                                                                    ),
                                                              );
                                                              currentHours =
                                                                  projectorData
                                                                      .hours;
                                                            }

                                                            context.push(
                                                              '/dashboard/detail/${schedule.classroom}',
                                                              extra:
                                                                  currentHours,
                                                            );
                                                          },
                                                          hoverColor:
                                                              theme.hoverColor,
                                                          splashColor: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 14,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              border: Border.all(
                                                                color: isDark
                                                                    ? Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.04,
                                                                          )
                                                                    : Colors
                                                                          .black
                                                                          .withOpacity(
                                                                            0.03,
                                                                          ),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 4,
                                                                  height: 40,
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            14,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: theme
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                          0.5,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ),
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
                                                                              16,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            6,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            FontAwesomeIcons.locationDot,
                                                                            size:
                                                                                12,
                                                                            color:
                                                                                isDark
                                                                                ? Colors.grey[600]
                                                                                : Colors.grey[500],
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                            schedule.classroom,
                                                                            style: TextStyle(
                                                                              color: isDark
                                                                                  ? Colors.grey[500]
                                                                                  : Colors.grey[600],
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                16,
                                                                          ),
                                                                          Icon(
                                                                            Icons.access_time_rounded,
                                                                            size:
                                                                                12,
                                                                            color:
                                                                                isDark
                                                                                ? Colors.grey[600]
                                                                                : Colors.grey[500],
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Text(
                                                                            "${schedule.startTime} - ${schedule.endTime}",
                                                                            style: TextStyle(
                                                                              color: isDark
                                                                                  ? Colors.grey[500]
                                                                                  : Colors.grey[600],
                                                                              fontSize: 13,
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
                                                                              color: Colors.grey[600],
                                                                              size: 20,
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
                                                                                                    "Edit Class Schedule",
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
                                                                                                              "COURSE NAME",
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
                                                                                                              "CLASSROOM",
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
                                                                                                      const SizedBox(
                                                                                                        height: 16,
                                                                                                      ),
                                                                                                      Text(
                                                                                                        "Adjust Class Schedule:",
                                                                                                        style: TextStyle(
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                          fontSize: 16,
                                                                                                        ),
                                                                                                      ),
                                                                                                      const SizedBox(
                                                                                                        height: 8,
                                                                                                      ),
                                                                                                      InkWell(
                                                                                                        splashColor: Colors.transparent,
                                                                                                        onTap: () async {
                                                                                                          final DateTime? pickedDate = await showDatePicker(
                                                                                                            context: context,
                                                                                                            initialDate: currentDate,
                                                                                                            firstDate: DateTime(
                                                                                                              2020,
                                                                                                            ),
                                                                                                            lastDate: DateTime(
                                                                                                              2035,
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
                                                                                                                      datePickerTheme: DatePickerThemeData(
                                                                                                                        backgroundColor: theme.scaffoldBackgroundColor,
                                                                                                                        shape: RoundedRectangleBorder(
                                                                                                                          borderRadius: BorderRadius.circular(
                                                                                                                            20,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        dayStyle: TextStyle(
                                                                                                                          fontSize: 12,
                                                                                                                          color: theme.primaryColor,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    child: child!,
                                                                                                                  );
                                                                                                                },
                                                                                                          );

                                                                                                          if (pickedDate !=
                                                                                                              null) {
                                                                                                            setState(
                                                                                                              () {
                                                                                                                currentDate = pickedDate;
                                                                                                              },
                                                                                                            );
                                                                                                          }
                                                                                                        },
                                                                                                        borderRadius: BorderRadius.circular(
                                                                                                          12,
                                                                                                        ),
                                                                                                        child: Container(
                                                                                                          width: double.infinity,
                                                                                                          padding: const EdgeInsets.all(
                                                                                                            14,
                                                                                                          ),
                                                                                                          decoration: BoxDecoration(
                                                                                                            border: Border.all(
                                                                                                              color: theme.primaryColor.withOpacity(
                                                                                                                0.2,
                                                                                                              ),
                                                                                                            ),
                                                                                                            borderRadius: BorderRadius.circular(
                                                                                                              12,
                                                                                                            ),
                                                                                                          ),
                                                                                                          child: Row(
                                                                                                            children: [
                                                                                                              Icon(
                                                                                                                Icons.edit_calendar_rounded,
                                                                                                                color: theme.primaryColor,
                                                                                                              ),
                                                                                                              const SizedBox(
                                                                                                                width: 10,
                                                                                                              ),
                                                                                                              Expanded(
                                                                                                                child: Column(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  children: [
                                                                                                                    Text(
                                                                                                                      "Class Date",
                                                                                                                      style: TextStyle(
                                                                                                                        fontSize: 12,
                                                                                                                        color: Colors.grey[600],
                                                                                                                        letterSpacing: 1.1,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    const SizedBox(
                                                                                                                      height: 3,
                                                                                                                    ),
                                                                                                                    Text(
                                                                                                                      DateFormat(
                                                                                                                        'd MMMM yyyy',
                                                                                                                      ).format(
                                                                                                                        currentDate,
                                                                                                                      ),
                                                                                                                      style: const TextStyle(
                                                                                                                        fontWeight: FontWeight.bold,
                                                                                                                        fontSize: 16,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      const SizedBox(
                                                                                                        height: 16,
                                                                                                      ),
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          // Jam Mulai
                                                                                                          Expanded(
                                                                                                            child: InkWell(
                                                                                                              borderRadius: BorderRadius.circular(
                                                                                                                12,
                                                                                                              ),
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
                                                                                                                      "Start",
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
                                                                                                              borderRadius: BorderRadius.circular(
                                                                                                                12,
                                                                                                              ),
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
                                                                                                                      "End",
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
                                                                                                            "Cancel",
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
                                                                                                                    updatedScheduleDate: currentDate,
                                                                                                                    newStartTime: currentStart,
                                                                                                                    newEndTime: currentEnd,
                                                                                                                  ),
                                                                                                                );
                                                                                                            Navigator.pop(
                                                                                                              context,
                                                                                                            );
                                                                                                          },
                                                                                                          child: Text(
                                                                                                            "Save Schedule",
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
                                                                          // IconButton(
                                                                          //   icon: const Icon(
                                                                          //     Icons.delete_outline,
                                                                          //     color: Colors.redAccent,
                                                                          //     size: 20,
                                                                          //   ),
                                                                          //   onPressed: () {
                                                                          //     showDialog(
                                                                          //       context: context,
                                                                          //       builder:
                                                                          //           (
                                                                          //             context,
                                                                          //           ) => AlertDialog(
                                                                          //             title: const Text(
                                                                          //               "Hapus Jadwal?",
                                                                          //             ),
                                                                          //             content: Text(
                                                                          //               "Apakah Anda yakin ingin menghapus jadwal ${schedule.mataKuliah}? Tindakan ini dilakukan jika Dosen berhalangan hadir.",
                                                                          //             ),
                                                                          //             actions: [
                                                                          //               TextButton(
                                                                          //                 onPressed: () => Navigator.pop(
                                                                          //                   context,
                                                                          //                 ),
                                                                          //                 style: TextButton.styleFrom(
                                                                          //                   foregroundColor: Colors.black,
                                                                          //                 ),
                                                                          //                 child: const Text(
                                                                          //                   "Batal",
                                                                          //                 ),
                                                                          //               ),
                                                                          //               TextButton(
                                                                          //                 onPressed: () {
                                                                          //                   // BlocProvider.of<ScheduleBloc>(context).add(DeleteScheduleEvent(schedule.id));
                                                                          //                   Navigator.pop(
                                                                          //                     context,
                                                                          //                   );
                                                                          //                 },
                                                                          //                 style: TextButton.styleFrom(
                                                                          //                   foregroundColor: Colors.red,
                                                                          //                 ),
                                                                          //                 child: const Text(
                                                                          //                   "Hapus",
                                                                          //                 ),
                                                                          //               ),
                                                                          //             ],
                                                                          //           ),
                                                                          //     );
                                                                          //   },
                                                                          // ),
                                                                        ],
                                                                      )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
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
                                        index == groupedSchedules.length - 1
                                            ? SizedBox()
                                            : Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                ),
                                                child: Divider(
                                                  color: isDark
                                                      ? Colors.white
                                                            .withOpacity(0.04)
                                                      : Colors.black
                                                            .withOpacity(0.04),
                                                  indent: 8,
                                                  endIndent: 8,
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
