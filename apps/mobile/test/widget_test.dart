import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhis/main.dart';

void main() {
  testWidgets('renders the NHIS home page on mobile portrait', (tester) async {
    await _pumpHomeAtSize(tester, const Size(390, 844));

    expect(find.text('National Health Information System'), findsOneWidget);
    expect(find.text('NHIS'), findsOneWidget);
    expect(find.text('Secure nationwide healthcare platform'), findsOneWidget);
  });

  testWidgets('renders the NHIS home page on browser landscape', (
    tester,
  ) async {
    await _pumpHomeAtSize(tester, const Size(1280, 720));

    expect(find.text('National Health Information System'), findsOneWidget);
    expect(find.text('Digital records'), findsOneWidget);
    expect(find.text('Open health booklet'), findsOneWidget);
  });
}

Future<void> _pumpHomeAtSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const NhisMobileApp());
  await tester.pumpAndSettle();
}
