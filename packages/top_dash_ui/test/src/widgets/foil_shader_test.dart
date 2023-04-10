import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_dash_ui/top_dash_ui.dart';

void main() {
  group('FoilShader', () {
    const child = SizedBox(key: Key('child'));

    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(const FoilShader(package: null, child: child));
      await tester.pump();

      expect(find.byWidget(child), findsOneWidget);
    });
  });
}