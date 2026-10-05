import 'package:flutter/material.dart';
import 'package:safeplace/config/supabase_chave.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AcessoRelatorio { liberado, gratis, planos }

/// Plano de um usuário. No Supabase, uma linha da tabela `plano`.
/// Sem Supabase, a chave inclui o id para não misturar contas neste aparelho.
class PlanoController extends ChangeNotifier {
  bool ehPro = false;
  bool jaUsouRelatorioGratis = false;
  String? usuarioId;
  var _descartado = false;

  bool get _remoto => supabaseLigado && usuarioId != null;

  String get _chavePro => 'usuario:$usuarioId:ehPro';
  String get _chaveRelatorioGratis => 'usuario:$usuarioId:jaUsouRelatorioGratis';

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  Future<void> vincular(String id) async {
    usuarioId = id;
    await carregar();
  }

  Future<void> desvincular() async {
    usuarioId = null;
    ehPro = false;
    jaUsouRelatorioGratis = false;
    if (!_descartado) notifyListeners();
  }

  Future<void> carregar() async {
    if (usuarioId == null) {
      ehPro = false;
      jaUsouRelatorioGratis = false;
      if (!_descartado) notifyListeners();
      return;
    }
    if (supabaseLigado) {
      await _carregarRemoto();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_descartado) return;
    ehPro = prefs.getBool(_chavePro) ?? false;
    jaUsouRelatorioGratis = prefs.getBool(_chaveRelatorioGratis) ?? false;
    notifyListeners();
  }

  AcessoRelatorio acessoRelatorio() {
    if (ehPro) return AcessoRelatorio.liberado;
    if (!jaUsouRelatorioGratis) return AcessoRelatorio.gratis;
    return AcessoRelatorio.planos;
  }

  Future<void> assinarPro() async {
    if (usuarioId == null) return;
    ehPro = true;
    if (!_descartado) notifyListeners();
    if (_remoto) {
      await clienteSupabase.from('plano').update({'eh_pro': true}).eq('usuario_id', usuarioId!);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chavePro, true);
  }

  Future<void> marcarRelatorioGratisUsado() async {
    if (usuarioId == null) return;
    jaUsouRelatorioGratis = true;
    if (!_descartado) notifyListeners();
    if (_remoto) {
      await clienteSupabase
          .from('plano')
          .update({'ja_usou_relatorio_gratis': true})
          .eq('usuario_id', usuarioId!);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveRelatorioGratis, true);
  }

  Future<void> _carregarRemoto() async {
    final id = usuarioId!;
    var linha = await clienteSupabase.from('plano').select().eq('usuario_id', id).maybeSingle();
    if (linha == null) {
      await clienteSupabase.from('plano').insert({
        'usuario_id': id,
        'eh_pro': false,
        'ja_usou_relatorio_gratis': false,
      });
      linha = {
        'eh_pro': false,
        'ja_usou_relatorio_gratis': false,
      };
    }
    if (_descartado || usuarioId != id) return;
    ehPro = linha['eh_pro'] == true;
    jaUsouRelatorioGratis = linha['ja_usou_relatorio_gratis'] == true;
    notifyListeners();
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
