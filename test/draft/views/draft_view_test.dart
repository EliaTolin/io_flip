// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_domain/game_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:top_dash/draft/draft.dart';

import '../../helpers/helpers.dart';

class _MockDraftBloc extends Mock implements DraftBloc {}

void main() {
  group('DraftView', () {
    late DraftBloc draftBloc;

    const card1 = Card(
      id: '1',
      name: 'card1',
      description: '',
      rarity: true,
      image: '',
      design: 1,
      product: 1,
      frontend: 1,
      backend: 1,
    );

    const card2 = Card(
      id: '2',
      name: 'card2',
      description: '',
      rarity: true,
      image: '',
      design: 1,
      product: 1,
      frontend: 1,
      backend: 1,
    );

    const card3 = Card(
      id: '2',
      name: 'card2',
      description: '',
      rarity: true,
      image: '',
      design: 1,
      product: 1,
      frontend: 1,
      backend: 1,
    );

    void mockState(List<DraftState> states) {
      whenListen(
        draftBloc,
        Stream.fromIterable(states),
        initialState: states.first,
      );
    }

    setUp(() {
      draftBloc = _MockDraftBloc();
      const state = DraftState.initial();
      mockState([state]);
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpSubject(draftBloc: draftBloc);

      expect(find.byType(DraftView), findsOneWidget);
    });

    testWidgets('renders the loaded cards', (tester) async {
      mockState(
        [
          DraftState(
            cards: const [card1, card2],
            status: DraftStateStatus.cardLoaded,
          )
        ],
      );
      await tester.pumpSubject(draftBloc: draftBloc);

      expect(find.text('card1'), findsOneWidget);
      expect(find.text('card2'), findsOneWidget);
    });

    testWidgets('renders an error message when loading failed', (tester) async {
      mockState(
        [
          DraftState(
            cards: const [card1, card2],
            status: DraftStateStatus.cardFailed,
          )
        ],
      );
      await tester.pumpSubject(draftBloc: draftBloc);

      expect(
        find.text('Error generating cards, please try again in a few moments'),
        findsOneWidget,
      );
    });

    testWidgets('renders the status message', (tester) async {
      mockState(
        [
          DraftState(
            cards: const [card1, card2],
            status: DraftStateStatus.cardLoaded,
          )
        ],
      );
      await tester.pumpSubject(draftBloc: draftBloc);

      expect(find.text('Generating 3 of 3'), findsOneWidget);
    });

    testWidgets(
      'render the play button once deck is complete',
      (tester) async {
        mockState(
          [
            DraftState(
              cards: const [card1, card2, card3],
              status: DraftStateStatus.deckCompleted,
            )
          ],
        );
        await tester.pumpSubject(draftBloc: draftBloc);

        expect(find.text('Play'), findsOneWidget);
      },
    );

    testWidgets(
      'fetches a new card when the loading is finished',
      (tester) async {
        mockState(
          [
            DraftState.initial(),
            DraftState(
              cards: const [card1],
              status: DraftStateStatus.cardLoaded,
            ),
          ],
        );
        await tester.pumpSubject(draftBloc: draftBloc);

        verify(() => draftBloc.add(CardRequested())).called(1);
      },
    );

    testWidgets(
      'navigates to the game lobby when clicking on play',
      (tester) async {
        mockState(
          [
            DraftState(
              cards: const [card1, card2, card3],
              status: DraftStateStatus.deckCompleted,
            )
          ],
        );
        await tester.pumpSubject(draftBloc: draftBloc);

        await tester.tap(find.text('Play'));
        // TODO(erickzanardo): assert navigation when implemented.
      },
    );
  });
}

extension DraftViewTest on WidgetTester {
  Future<void> pumpSubject({
    required DraftBloc draftBloc,
  }) async {
    await mockNetworkImages(() {
      return pumpApp(
        BlocProvider.value(
          value: draftBloc,
          child: DraftView(),
        ),
      );
    });
  }
}