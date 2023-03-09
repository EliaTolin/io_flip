import 'package:game_domain/game_domain.dart';

/// {@template match_resolution_failure}
/// Throw when a round cannot be resolved.
/// {@endtemplate}
class MatchResolutionFailure implements Exception {
  /// {@macro match_resolution_failure}
  MatchResolutionFailure({
    required this.message,
    required this.stackTrace,
  });

  /// Message.
  final String message;

  /// StackTrace.
  final StackTrace stackTrace;
}

/// {@template match_solver}
/// A class with logic on how to solve match problems,
/// it includes methods to determine who won't the game
/// among other domain specific logic to matches.
/// {@endtemplate}
class MatchSolver {
  /// {@macro match_solver}
  const MatchSolver();

  /// Calculates and return the result of a match.
  MatchResult calculateMatchResult(Match match, MatchState state) {
    if (!state.isOver()) {
      throw MatchResolutionFailure(
        message: "Can't calculate the result of a match that "
            "hasn't finished yet.",
        stackTrace: StackTrace.current,
      );
    }

    var hostRounds = 0;
    var guestRounds = 0;

    for (var i = 0; i < state.hostPlayedCards.length; i++) {
      final roundResult = calculateRoundResult(
        match,
        state,
        i,
      );

      if (roundResult == MatchResult.host) {
        hostRounds++;
      } else if (roundResult == MatchResult.guest) {
        guestRounds++;
      }
    }

    if (hostRounds == guestRounds) {
      return MatchResult.draw;
    } else {
      return hostRounds > guestRounds ? MatchResult.host : MatchResult.guest;
    }
  }

  /// Calculates and return result of a round of match.
  ///
  /// Throws [MatchResolutionFailure] when trying to solve a round
  /// that isn't finished yet.
  MatchResult calculateRoundResult(Match match, MatchState state, int round) {
    if (state.hostPlayedCards.length > round &&
        state.guestPlayedCards.length > round) {
    } else {
      throw MatchResolutionFailure(
        message: "Can't calculate the result of a round that "
            "hasn't finished yet.",
        stackTrace: StackTrace.current,
      );
    }

    final hostCardId = state.hostPlayedCards[round];
    final guestCardId = state.guestPlayedCards[round];

    final hostCard =
        match.hostDeck.cards.firstWhere((card) => card.id == hostCardId);
    final guestCard =
        match.guestDeck.cards.firstWhere((card) => card.id == guestCardId);

    if (hostCard.power == guestCard.power) {
      return MatchResult.draw;
    } else {
      return hostCard.power > guestCard.power
          ? MatchResult.host
          : MatchResult.guest;
    }
  }

  /// Returns true when player, determined by [isHost] can play a card
  /// or if they need to await for their opponent to play first.
  bool canPlayCard(MatchState state, {required bool isHost}) {
    if (state.hostPlayedCards.length == state.guestPlayedCards.length) {
      return true;
    }

    if (isHost &&
        state.hostPlayedCards.length < state.guestPlayedCards.length) {
      return true;
    }

    if (!isHost &&
        state.hostPlayedCards.length > state.guestPlayedCards.length) {
      return true;
    }

    return false;
  }
}