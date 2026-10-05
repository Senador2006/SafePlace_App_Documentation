import 'package:flutter/material.dart';
import 'package:safeplace/services/auth_controller.dart';
import 'package:safeplace/theme/colors.dart';
import 'package:safeplace/widgets/campo_auth.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key, required this.onVoltar});

  final VoidCallback onVoltar;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  String? _erro;
  var _enviando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final auth = AuthScope.of(context);
    final erro = await auth.cadastrar(
      nome: _nome.text,
      email: _email.text,
      senha: _senha.text,
    );
    if (!mounted) return;
    if (erro != null) {
      setState(() {
        _erro = erro;
        _enviando = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePlaceColors.nightBlue,
      appBar: AppBar(title: const Text('Criar conta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const Text(
            'A conta guarda o seu plano. Os dados dos bairros continuam iguais para todo mundo.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.4,
              color: SafePlaceColors.lightGray,
            ),
          ),
          const SizedBox(height: 20),
          CampoAuth(
            controller: _nome,
            hint: 'Nome',
            icone: Icons.person_outline,
          ),
          const SizedBox(height: 12),
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
            onPressed: _enviando ? null : _cadastrar,
            style: FilledButton.styleFrom(
              backgroundColor: SafePlaceColors.safeBlue,
              foregroundColor: SafePlaceColors.white,
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(_enviando ? 'Criando...' : 'Criar conta'),
          ),
          TextButton(
            onPressed: widget.onVoltar,
            child: const Text('Já tenho conta'),
          ),
        ],
      ),
    );
  }
}
