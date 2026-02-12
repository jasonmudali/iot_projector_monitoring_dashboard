import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/mqtt/mqtt_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/schedule_bloc.dart';
import 'package:skripsi_iot_projector/page/bloc/theme/theme_bloc.dart';
import 'package:skripsi_iot_projector/page/dasbhoard.dart';
import 'package:skripsi_iot_projector/page/home.dart';
import 'package:skripsi_iot_projector/page/schedule.dart';
import 'package:skripsi_iot_projector/repository/mqtt_repository.dart';
import 'package:skripsi_iot_projector/theme_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  initialLocation: '/dashboard',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomePage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const Dashboard(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (context, state) => const Schedule(),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() async {
  usePathUrlStrategy();

  await Supabase.initialize(
    url: 'https://gdphnxqxilqmslqdoabx.supabase.co',
    anonKey: 'sb_publishable_9AcAocwpvzIqNdhlP05Jtg_U4PK63gT',
  );

  final mqttRepository = MqttRepository();
  await mqttRepository.initializeMqtt();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<MqttBloc>(
          create: (context) {
            return MqttBloc(mqttRepository)..add(StartListening());
          },
        ),
        BlocProvider(create: (context) => ScheduleBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.watch<ThemeBloc>().state;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Skripsi IoT Projector',
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeBloc.themeMode,
      routerConfig: _router,
    );
  }
}
