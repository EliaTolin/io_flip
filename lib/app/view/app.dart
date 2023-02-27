import 'package:flutter/material.dart';
import 'package:game_client/game_client.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:top_dash/app_lifecycle/app_lifecycle.dart';
import 'package:top_dash/audio/audio_controller.dart';
import 'package:top_dash/l10n/l10n.dart';
import 'package:top_dash/match_making/match_maker.dart';
import 'package:top_dash/router/router.dart';
import 'package:top_dash/settings/persistence/persistence.dart';
import 'package:top_dash/settings/settings.dart';
import 'package:top_dash/style/palette.dart';
import 'package:top_dash/style/snack_bar.dart';

typedef CreateAudioController = AudioController Function();

@visibleForTesting
AudioController updateAudioController(
  BuildContext context,
  SettingsController settings,
  ValueNotifier<AppLifecycleState> lifecycleNotifier,
  AudioController? audio, {
  CreateAudioController createAudioController = AudioController.new,
}) {
  return audio ?? createAudioController()
    ..initialize()
    ..attachSettings(settings)
    ..attachLifecycleNotifier(lifecycleNotifier);
}

class App extends StatefulWidget {
  const App({
    required this.settingsPersistence,
    required this.gameClient,
    required this.matchMaker,
    this.router,
    super.key,
  });

  final SettingsPersistence settingsPersistence;

  final GameClient gameClient;

  final MatchMaker matchMaker;

  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final router = widget.router ?? createRouter();

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider.value(value: widget.gameClient),
          Provider.value(value: widget.matchMaker),
          Provider<SettingsController>(
            lazy: false,
            create: (context) => SettingsController(
              persistence: widget.settingsPersistence,
            )..loadStateFromPersistence(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            // Ensures that the AudioController is created on startup,
            // and not "only when it's needed", as is default behavior.
            // This way, music starts immediately.
            lazy: false,
            create: (context) => AudioController()..initialize(),
            update: updateAudioController,
            dispose: (context, audio) => audio.dispose(),
          ),
          Provider(
            create: (context) => Palette(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final palette = context.watch<Palette>();

            return MaterialApp.router(
              title: 'Top Dash',
              theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: palette.darkPen,
                  background: palette.backgroundMain,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(
                    color: palette.ink,
                  ),
                ),
                useMaterial3: true,
              ),
              routeInformationProvider: router.routeInformationProvider,
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              scaffoldMessengerKey: scaffoldMessengerKey,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
