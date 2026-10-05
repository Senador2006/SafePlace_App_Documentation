import 'package:flutter/material.dart';
import 'package:safeplace/services/auth_controller.dart';
import 'package:safeplace/theme/colors.dart';
import 'package:safeplace/widgets/brand_logo.dart';
import 'package:safeplace/widgets/campo_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onCriarConta});

  final VoidCallback onCriarConta;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  String? _erro;
  var _enviando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final auth = AuthScope.of(context);
    final erro = await auth.entrar(email: _email.text, senha: _senha.text);
    if (!mounted) return;
    if (erro != null) {
      setState(() {
        _erro = erro;
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePlaceColors.nightBlue,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Center(child: SafePlaceLogo(size: 72)),
            const SizedBox(height: 16),
            const Center(child: SafePlaceWordmark(fontSize: 32)),
            const SizedBox(height: 8),
            const Text(
              'Entre para consultar os bairros com o seu plano.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: SafePlaceColors.mediumGray,
              ),
            ),
            const SizedBox(height: 28),
            CampoAuth(
              controller: _email,
              hint: 'E-mail',
              icone: Icons.mail_outline,
              email: true,
            ),
            const SizedBox(height: 12),
            CampoAuth(
              controller: _senha,
              hint: 'Senha',
              icone: Icons.lock_outline,
              senha: true,
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(
                _erro!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: SafePlaceColors.highRisk,
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _enviando ? null : _entrar,
              style: FilledButton.styleFrom(
                backgroundColor: SafePlaceColors.safeBlue,
                foregroundColor: SafePlaceColors.white,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(_enviando ? 'Entrando...' : 'Entrar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onCriarConta,
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
