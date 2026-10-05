import 'package:flutter/material.dart';
import 'package:safeplace/config/supabase_chave.dart';
import 'package:safeplace/screens/entrada_screen.dart';
import 'package:safeplace/services/auth_controller.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:safeplace/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await iniciarSupabase();
  final auth = AuthController();
  final plano = PlanoController();
  await auth.carregar();
  if (auth.atual != null) await plano.vincular(auth.atual!.id);
  runApp(SafePlaceApp(auth: auth, plano: plano));
}

class SafePlaceApp extends StatefulWidget {
  const SafePlaceApp({super.key, this.auth, this.plano});

  final AuthController? auth;
  final PlanoController? plano;

  @override
  State<SafePlaceApp> createState() => _SafePlaceAppState();
}

class _SafePlaceAppState extends State<SafePlaceApp> {
  late final AuthController _auth;
  late final PlanoController _plano;
  late final bool _dono;

  @override
  void initState() {
    super.initState();
    _dono = widget.auth == null;
    _auth = widget.auth ?? (AuthController()..carregar());
    _plano = widget.plano ?? PlanoController();
  }

  @override
  void dispose() {
    if (_dono) {
      _auth.dispose();
      _plano.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _auth,
      child: PlanoScope(
        controller: _plano,
        child: MaterialApp(
          title: 'SafePlace',
          debugShowCheckedModeBanner: false,
          theme: SafePlaceTheme.dark(),
          home: const EntradaScreen(),
        ),
      ),
    );
  }
}
