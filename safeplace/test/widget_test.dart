import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplace/main.dart';
import 'package:safeplace/screens/cadastro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> montar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding.zero;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const SafePlaceApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final campos = find.descendant(
      of: find.byType(CadastroScreen),
      matching: find.byType(TextField),
    );
    await tester.enterText(campos.at(0), 'Ana');
    await tester.enterText(campos.at(1), 'ana@fiap.com');
    await tester.enterText(campos.at(2), '123456');
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (var i = 0; i < 20 && find.text('Pinheiros').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Pinheiros'), findsOneWidget);
  }

  testWidgets('Tela inicial mostra busca e mapa', (tester) async {
    await montar(tester);

    expect(find.text('Buscar bairro em São Paulo'), findsOneWidget);
    expect(find.text('Planos'), findsOneWidget);
    expect(find.text('Patrocinado'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pinhe');
    await tester.pump();

    expect(find.text('Pinheiros'), findsOneWidget);
    expect(find.text('Moema'), findsNothing);

    await tester.tap(find.text('Pinheiros'));
    await tester.pump();

    expect(find.text('Furtos'), findsWidgets);
    expect(find.text('Roubos'), findsWidgets);
    expect(find.textContaining('Criminalidade'), findsOneWidget);
    expect(find.text('Ver relatório detalhado'), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);
  });

  testWidgets('Relatorio gratuito unico e depois a tela de planos', (tester) async {
    await montar(tester);

    await tester.tap(find.text('Pinheiros'));
    await tester.pump();
    await tester.tap(find.text('Ver relatório detalhado'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('relatório gratuito'), findsOneWidget);
    expect(find.text('Evolução das ocorrências'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Ofertas de parceiros'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Ofertas de parceiros'), findsOneWidget);
    expect(find.text('Câmeras de segurança'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Ver relatório detalhado'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Assinar Pro'), findsOneWidget);
    expect(find.text('Ofertas de parceiros'), findsNothing);
  });

  testWidgets('Assinar Pro remove o anuncio da tela principal', (tester) async {
    await montar(tester);

    await tester.tap(find.text('Planos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Gratuito'), findsOneWidget);
    expect(find.text('Plano atual'), findsOneWidget);

    await tester.tap(find.text('Assinar Pro'));
    await tester.pump();

    expect(find.text('Assinatura Pro ativa neste aparelho.'), findsOneWidget);
    expect(find.text('Assinar Pro'), findsNothing);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Assinatura Pro ativa neste aparelho.'), findsNothing);
    expect(find.text('Buscar bairro em São Paulo'), findsOneWidget);
    expect(find.text('Patrocinado'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Pro'), findsOneWidget);
  });
}
