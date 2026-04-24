import 'package:flutter/material.dart';
import 'package:skripsi_iot_projector/model/sidebar_item.dart';
import 'package:skripsi_iot_projector/page/bloc/schedule/schedule_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatefulWidget {
  Sidebar({super.key, required this.navigationShell, this.isDesktop = true});

  final StatefulNavigationShell navigationShell;
  final bool isDesktop;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    List<SidebarItem> sidebarItems = [
      SidebarItem(
        title: 'Dashboard',
        route: '/dashboard',
        icon: Icons.dashboard,
      ),
      SidebarItem(title: 'Schedule', route: '/schedule', icon: Icons.schedule),
    ];

    return Container(
      color: Theme.of(context).canvasColor,
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 26.0,
        left: 20.0,
        right: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: sidebarItems.length,
                itemBuilder: (context, index) {
                  final item = sidebarItems[index];
                  final isSelected =
                      widget.navigationShell.currentIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(13),
                        hoverColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (index == 1 &&
                              widget.navigationShell.currentIndex != 1) {
                            context.read<ScheduleBloc>().add(
                              LoadScheduleEvent(),
                            );
                          }
                          widget.navigationShell.goBranch(
                            index,
                            initialLocation:
                                index == widget.navigationShell.currentIndex,
                          );

                          if (!widget.isDesktop) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected
                                    ? Theme.of(context).focusColor
                                    : Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                item.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).focusColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
                hoverColor: Theme.of(context).hoverColor,
                splashColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.brightness_4),
                      SizedBox(width: 5),
                      Text("Switch Theme"),
                    ],
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
