import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skripsi_iot_projector/page/bloc/schedule_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/theme/theme_bloc.dart';
import 'package:skripsi_iot_projector/page/dasbhoard.dart';

class HomePage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  HomePage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          Container(
            color: Theme.of(context).canvasColor,
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NavigationRail(
                    backgroundColor: Theme.of(context).canvasColor,
                    extended: true,
                    minExtendedWidth: 240,
                    selectedLabelTextStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    onDestinationSelected: (int index) {
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );

                      if (index == 1) {
                        context.read<ScheduleBloc>().add(LoadScheduleEvent());
                      }
                    },
                    selectedIndex: navigationShell.currentIndex,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.monitor),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.calendar_today),
                        label: Text('Schedule'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 20.0),
                  child: IconButton(
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                    icon: Icon(Icons.brightness_4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 50.0,
              ),
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
