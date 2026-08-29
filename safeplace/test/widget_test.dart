import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplace/main.dart';

void main() {
  testWidgets('Tela inicial mostra busca e mapa', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SafePlaceApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Buscar bairro em São Paulo'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Pinheiros'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pinhe');
    await tester.pump();

    expect(find.text('Pinheiros'), findsOneWidget);
    expect(find.text('Moema'), findsNothing);

    await tester.tap(find.text('Pinheiros'));
    await tester.pump();

    expect(find.text('Furtos'), findsOneWidget);
    expect(find.text('Roubos'), findsOneWidget);
  });
}
