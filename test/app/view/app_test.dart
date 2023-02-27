import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_client/game_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:top_dash/app/app.dart';
import 'package:top_dash/audio/audio_controller.dart';
import 'package:top_dash/draft/draft.dart';
import 'package:top_dash/main_menu/main_menu_screen.dart';
import 'package:top_dash/match_making/match_maker.dart';
import 'package:top_dash/settings/persistence/persistence.dart';
import 'package:top_dash/settings/settings.dart';
import 'package:top_dash/settings/settings_screen.dart';
import 'package:top_dash/style/snack_bar.dart';

import '../../helpers/helpers.dart';

class _MockBuildContext extends Mock implements BuildContext {}

class _MockAudioController extends Mock implements AudioController {}

class _MockSettingsController extends Mock implements SettingsController {}

class _MockLifecycleNotifier extends Mock
    implements ValueNotifier<AppLifecycleState> {}

class _MockGameClient extends Mock implements GameClient {}

class _MockMatchMaker extends Mock implements MatchMaker {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App', () {
    testWidgets('can show a snackbar', (tester) async {
      await tester.pumpWidget(
        App(
          settingsPersistence: MemoryOnlySettingsPersistence(),
          gameClient: _MockGameClient(),
          matchMaker: _MockMatchMaker(),
        ),
      );

      showSnackBar('SnackBar');

      await tester.pumpAndSettle();

      expect(find.text('SnackBar'), findsOneWidget);
    });

    group('updateAudioController', () {
      setUpAll(() {
        registerFallbackValue(_MockSettingsController());
        registerFallbackValue(_MockLifecycleNotifier());
      });

      test('initializes, attach to setting and lifecycle', () {
        final buildContext = _MockBuildContext();
        final settingsController = _MockSettingsController();
        final lifecycle = _MockLifecycleNotifier();
        final audioController = _MockAudioController();

        when(audioController.initialize).thenAnswer((_) async {});
        when(() => audioController.attachSettings(any())).thenAnswer((_) {});
        when(() => audioController.attachLifecycleNotifier(any()))
            .thenAnswer((_) {});

        final result = updateAudioController(
          buildContext,
          settingsController,
          lifecycle,
          audioController,
        );

        verify(() => audioController.attachSettings(any())).called(1);
        verify(() => audioController.attachLifecycleNotifier(any())).called(1);

        expect(result, audioController);
      });

      test('returns a new instance when audio controller is null', () {
        final buildContext = _MockBuildContext();
        final audioController = _MockAudioController();

        when(audioController.initialize).thenAnswer((_) async {});
        when(() => audioController.attachSettings(any())).thenAnswer((_) {});
        when(() => audioController.attachLifecycleNotifier(any()))
            .thenAnswer((_) {});

        final result = updateAudioController(
          buildContext,
          SettingsController(persistence: MemoryOnlySettingsPersistence()),
          ValueNotifier(AppLifecycleState.paused),
          null,
          createAudioController: () => audioController,
        );

        verify(() => audioController.attachSettings(any())).called(1);
        verify(() => audioController.attachLifecycleNotifier(any())).called(1);

        expect(result, audioController);
      });
    });

    group('when in portrait mode', () {
      testWidgets('renders the app', (tester) async {
        tester.setPortraitDisplaySize();
        await tester.pumpWidget(
          App(
            settingsPersistence: MemoryOnlySettingsPersistence(),
            gameClient: _MockGameClient(),
            matchMaker: _MockMatchMaker(),
          ),
        );

        expect(find.byType(MainMenuScreen), findsOneWidget);
      });

      testWidgets('can navigate to the game page', (tester) async {
        tester.setPortraitDisplaySize();
        await tester.pumpWidget(
          App(
            settingsPersistence: MemoryOnlySettingsPersistence(),
            gameClient: _MockGameClient(),
            matchMaker: _MockMatchMaker(),
          ),
        );

        await tester.tap(find.text('Play'));
        await tester.pumpAndSettle();

        expect(find.byType(DraftPage), findsOneWidget);
      });

      testWidgets('can navigate to the settings page', (tester) async {
        tester.setPortraitDisplaySize();
        await tester.pumpWidget(
          App(
            settingsPersistence: MemoryOnlySettingsPersistence(),
            gameClient: _MockGameClient(),
            matchMaker: _MockMatchMaker(),
          ),
        );

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);
      });

      testWidgets(
        'can navigate to the settings page and go back',
        (tester) async {
          tester.setPortraitDisplaySize();
          await tester.pumpWidget(
            App(
              settingsPersistence: MemoryOnlySettingsPersistence(),
              gameClient: _MockGameClient(),
              matchMaker: _MockMatchMaker(),
            ),
          );

          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Back'));
          await tester.pumpAndSettle();

          expect(find.byType(SettingsScreen), findsNothing);
        },
      );
    });

    group('when in landscape mode', () {
      testWidgets('renders the app', (tester) async {
        tester.setLandspaceDisplaySize();
        await tester.pumpWidget(
          App(
            settingsPersistence: MemoryOnlySettingsPersistence(),
            gameClient: _MockGameClient(),
            matchMaker: _MockMatchMaker(),
          ),
        );

        expect(find.byType(MainMenuScreen), findsOneWidget);
      });

      testWidgets('can navigate to the game page', (tester) async {
        tester.setLandspaceDisplaySize();

        await tester.pumpWidget(
          App(
            settingsPersistence: MemoryOnlySettingsPersistence(),
            gameClient: _MockGameClient(),
            matchMaker: _MockMatchMaker(),
          ),
        );

        await tester.tap(find.text('Play'));
        await tester.pumpAndSettle();

        expect(find.byType(DraftPage), findsOneWidget);
      });

      testWidgets('can navigate to the settings page', (tester) async {
        tester.setLandspaceDisplaySize();

        await tester.pumpWidget(
          App(
            settingsPersistence: MemoryOnlySettingsPersistence(),
            gameClient: _MockGameClient(),
            matchMaker: _MockMatchMaker(),
          ),
        );

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);
      });

      testWidgets(
        'can navigate to the settings page and go back',
        (tester) async {
          tester.setLandspaceDisplaySize();

          await tester.pumpWidget(
            App(
              settingsPersistence: MemoryOnlySettingsPersistence(),
              gameClient: _MockGameClient(),
              matchMaker: _MockMatchMaker(),
            ),
          );

          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Back'));
          await tester.pumpAndSettle();

          expect(find.byType(SettingsScreen), findsNothing);
        },
      );
    });
  });
}
