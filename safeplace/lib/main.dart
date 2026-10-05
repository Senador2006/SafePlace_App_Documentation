import 'package:flutter/material.dart';
import 'package:safeplace/screens/home_screen.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:safeplace/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final plano = PlanoController();
  await plano.carregar();
  runApp(SafePlaceApp(plano: plano));
}

class SafePlaceApp extends StatefulWidget {
  const SafePlaceApp({super.key, this.plano});

  final PlanoController? plano;

  @override
  State<SafePlaceApp> createState() => _SafePlaceAppState();
}

class _SafePlaceAppState extends State<SafePlaceApp> {
  late final PlanoController _plano;
  late final bool _donoDoPlano;

  @override
  void initState() {
    super.initState();
    _donoDoPlano = widget.plano == null;
    _plano = widget.plano ?? (PlanoController()..carregar());
  }

  @override
  void dispose() {
    if (_donoDoPlano) _plano.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlanoScope(
      controller: _plano,
      child: MaterialApp(
        title: 'SafePlace',
        debugShowCheckedModeBanner: false,
        theme: SafePlaceTheme.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}
