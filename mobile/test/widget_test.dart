import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velma_bank/main.dart';

void main() {
  testWidgets('Login and connection controls fit a small Android viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VelmaBank());
    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.byTooltip('Connection settings'));
    await tester.pumpAndSettle();
    expect(find.text('Allow HTTP lab transport'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
