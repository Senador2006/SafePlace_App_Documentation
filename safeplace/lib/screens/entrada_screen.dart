import 'package:flutter/material.dart';
import 'package:safeplace/screens/cadastro_screen.dart';
import 'package:safeplace/screens/home_screen.dart';
import 'package:safeplace/screens/login_screen.dart';
import 'package:safeplace/services/auth_controller.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:safeplace/theme/colors.dart';

class EntradaScreen extends StatefulWidget {
  const EntradaScreen({super.key});

  @override
  State<EntradaScreen> createState() => _EntradaScreenState();
}

class _EntradaScreenState extends State<EntradaScreen> {
  var _cadastro = false;
  String? _planoVinculado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = AuthScope.of(context);
    final id = auth.atual?.id;
    if (!auth.pronto || id == null) {
      _planoVinculado = null;
      return;
    }
    if (_planoVinculado == id) return;
    _planoVinculado = id;
    PlanoScope.of(context).vincular(id);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    if (!auth.pronto) {
      return const Scaffold(
        backgroundColor: SafePlaceColors.nightBlue,
        body: Center(
          child: CircularProgressIndicator(color: SafePlaceColors.safeBlue),
        ),
      );
    }
    if (auth.atual != null) return const HomeScreen();
    if (_cadastro) {
      return CadastroScreen(onVoltar: () => setState(() => _cadastro = false));
    }
    return LoginScreen(onCriarConta: () => setState(() => _cadastro = true));
  }
}
