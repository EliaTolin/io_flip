// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:game_domain/game_domain.dart';
import 'package:match_repository/match_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_client/web_socket_client.dart';

import '../../../routes/public/matches/connect.dart' as route;

class _MockMatchRepository extends Mock implements MatchRepository {}

void main() {
  late HttpServer server;
  late MatchRepository matchRepository;

  const matchId = 'matchId';

  Future<WebSocket> startSocket({bool host = true}) async {
    server = await serve(
      (context) => route.onRequest(
        context.provide<MatchRepository>(() => matchRepository),
      ),
      InternetAddress.anyIPv4,
      0,
    );
    final socket = WebSocket(
      Uri.parse('ws://localhost:${server.port}?host=$host&matchId=$matchId'),
    );
    return socket;
  }

  group('GET /matches/connect', () {
    setUp(() {
      matchRepository = _MockMatchRepository();
    });

    test('establishes connection and updates host connectivity', () async {
      when(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: any<bool>(named: 'active'),
        ),
      ).thenAnswer(
        (_) async {},
      );
      when(
        () => matchRepository.getPlayerConnectivity(
          matchId: matchId,
          isHost: true,
        ),
      ).thenAnswer((_) async => false);

      final socket = await startSocket();

      await untilCalled(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: true,
        ),
      );
      verify(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: true,
        ),
      ).called(1);

      socket.send('test');

      await expectLater(
        socket.messages,
        emits(
          jsonEncode(
            const WebSocketMessage(message: MessageType.connected).toJson(),
          ),
        ),
      );

      socket.close();

      await untilCalled(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: false,
        ),
      );
      verify(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: false,
        ),
      ).called(1);
    });

    test('establishes connection and updates guest connectivity', () async {
      when(
        () => matchRepository.setGuestConnectivity(
          match: matchId,
          active: any<bool>(named: 'active'),
        ),
      ).thenAnswer(
        (_) async {},
      );
      when(
        () => matchRepository.getPlayerConnectivity(
          matchId: matchId,
          isHost: false,
        ),
      ).thenAnswer((_) async => false);

      final socket = await startSocket(host: false);

      await untilCalled(
        () => matchRepository.setGuestConnectivity(
          match: matchId,
          active: true,
        ),
      );
      verify(
        () => matchRepository.setGuestConnectivity(
          match: matchId,
          active: true,
        ),
      ).called(1);

      socket.send('test');

      await expectLater(
        socket.messages,
        emits(
          jsonEncode(
            const WebSocketMessage(message: MessageType.connected).toJson(),
          ),
        ),
      );

      socket.close();

      await untilCalled(
        () => matchRepository.setGuestConnectivity(
          match: matchId,
          active: false,
        ),
      );
      verify(
        () => matchRepository.setGuestConnectivity(
          match: matchId,
          active: false,
        ),
      ).called(1);
    });

    test('throws when player is already connected', () async {
      when(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: any<bool>(named: 'active'),
        ),
      ).thenAnswer(
        (_) async {},
      );
      when(
        () => matchRepository.getPlayerConnectivity(
          matchId: matchId,
          isHost: true,
        ),
      ).thenAnswer((_) async => true);

      final socket = await startSocket();

      await untilCalled(
        () => matchRepository.getPlayerConnectivity(
          matchId: matchId,
          isHost: true,
        ),
      );
      verify(
        () => matchRepository.getPlayerConnectivity(
          matchId: matchId,
          isHost: true,
        ),
      ).called(1);

      final message = WebSocketMessage.fromJson(
        jsonDecode(await socket.messages.first as String)
            as Map<String, dynamic>,
      );

      expect(
        message,
        equals(
          const WebSocketMessage(error: ErrorType.playerAlreadyConnected),
        ),
      );

      socket.close();
    });

    test('throws when cannot update player connectivity', () async {
      when(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: true,
        ),
      ).thenThrow(Exception('oops'));

      when(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: false,
        ),
      ).thenAnswer(
        (_) async {},
      );

      when(
        () => matchRepository.getPlayerConnectivity(
          matchId: matchId,
          isHost: true,
        ),
      ).thenAnswer((_) async => false);

      final socket = await startSocket();

      await untilCalled(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: true,
        ),
      );
      verify(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: true,
        ),
      ).called(1);

      await expectLater(
        socket.messages,
        emits(
          jsonEncode(
            const WebSocketMessage(error: ErrorType.firebaseException).toJson(),
          ),
        ),
      );

      socket.close();

      await untilCalled(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: false,
        ),
      );
      verify(
        () => matchRepository.setHostConnectivity(
          match: matchId,
          active: false,
        ),
      ).called(1);
    });
  });
}