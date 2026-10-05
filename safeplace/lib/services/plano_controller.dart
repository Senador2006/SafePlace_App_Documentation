import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AcessoRelatorio { liberado, gratis, planos }

/// Plano salvo no aparelho: `ehPro` e `jaUsouRelatorioGratis`.
class PlanoController extends ChangeNotifier {
  static const chavePro = 'ehPro';
  static const chaveRelatorioGratis = 'jaUsouRelatorioGratis';

  bool ehPro = false;
  bool jaUsouRelatorioGratis = false;
  var _descartado = false;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    if (_descartado) return;
    ehPro = prefs.getBool(chavePro) ?? false;
    jaUsouRelatorioGratis = prefs.getBool(chaveRelatorioGratis) ?? false;
    notifyListeners();
  }

  AcessoRelatorio acessoRelatorio() {
    if (ehPro) return AcessoRelatorio.liberado;
    if (!jaUsouRelatorioGratis) return AcessoRelatorio.gratis;
    return AcessoRelatorio.planos;
  }

  Future<void> assinarPro() async {
    ehPro = true;
    if (!_descartado) notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chavePro, true);
  }

  Future<void> marcarRelatorioGratisUsado() async {
    jaUsouRelatorioGratis = true;
    if (!_descartado) notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chaveRelatorioGratis, true);
  }
}

class PlanoScope extends InheritedNotifier<PlanoController> {
  const PlanoScope({
    super.key,
    required PlanoController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlanoController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlanoScope>();
    assert(scope != null, 'PlanoScope não encontrado');
    return scope!.notifier!;
  }
}
