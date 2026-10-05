import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:safeplace/config/supabase_chave.dart';
import 'package:safeplace/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String hashSenha(String senha) {
  return sha256.convert(utf8.encode('safeplace:$senha')).toString();
}

String mensagemAuth(AuthException erro) {
  final codigo = (erro.code ?? '').toLowerCase();
  final texto = erro.message.toLowerCase();
  if (codigo == 'invalid_credentials' || texto.contains('invalid login')) {
    return 'E-mail ou senha incorretos.';
  }
  if (codigo == 'user_already_exists' ||
      codigo == 'email_exists' ||
      texto.contains('already registered') ||
      texto.contains('already been registered')) {
    return 'Já existe uma conta com esse e-mail.';
  }
  if (codigo == 'email_not_confirmed' || texto.contains('email not confirmed')) {
    return 'Confirme o e-mail antes de entrar.';
  }
  if (codigo == 'over_email_send_rate_limit' ||
      codigo == 'email_address_invalid' ||
      texto.contains('rate limit') ||
      texto.contains('email address')) {
    return 'O Supabase não conseguiu enviar o e-mail de confirmação. '
        'No painel, em Authentication → Sign In / Providers → Email, desligue Confirm email.';
  }
  return 'Não foi possível concluir agora.';
}

/// Conta no Supabase quando [supabaseLigado]; senão, conta neste aparelho.
class AuthController extends ChangeNotifier {
  static const _chaveUsuarios = 'auth.usuarios';
  static const _chaveSessao = 'auth.sessao';

  Usuario? atual;
  var pronto = false;
  var _descartado = false;

  bool get _remoto => supabaseLigado;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  Future<void> carregar() async {
    if (_remoto) {
      final user = clienteSupabase.auth.currentUser;
      if (user != null) atual = _deAuth(user);
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (_descartado) return;
      final sessao = prefs.getString(_chaveSessao);
      if (sessao != null) {
        atual = _usuarios(prefs).where((usuario) => usuario.id == sessao).firstOrNull;
        if (atual == null) await prefs.remove(_chaveSessao);
      }
    }
    pronto = true;
    if (!_descartado) notifyListeners();
  }

  /// `null` quando entra. Texto quando o e-mail ou a senha não conferem.
  Future<String?> entrar({
    required String email,
    required String senha,
  }) async {
    if (_remoto) return _entrarRemoto(email: email, senha: senha);
    return _entrarLocal(email: email, senha: senha);
  }

  /// `null` quando a conta é criada e a sessão já fica aberta.
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final validacao = _validar(nome: nome, email: email, senha: senha);
    if (validacao != null) return validacao;
    if (_remoto) {
      return _cadastrarRemoto(nome: nome.trim(), email: email.trim().toLowerCase(), senha: senha);
    }
    return _cadastrarLocal(nome: nome.trim(), email: email.trim().toLowerCase(), senha: senha);
  }

  Future<void> sair() async {
    if (_remoto) {
      await clienteSupabase.auth.signOut();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chaveSessao);
    }
    atual = null;
    if (!_descartado) notifyListeners();
  }

  Future<String?> _entrarRemoto({
    required String email,
    required String senha,
  }) async {
    try {
      final resposta = await clienteSupabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: senha,
      );
      final user = resposta.user;
      if (user == null || resposta.session == null) {
        return 'Confirme o e-mail antes de entrar.';
      }
      atual = _deAuth(user);
      if (!_descartado) notifyListeners();
      return null;
    } on AuthException catch (erro) {
      return mensagemAuth(erro);
    }
  }

  Future<String?> _cadastrarRemoto({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final resposta = await clienteSupabase.auth.signUp(
        email: email,
        password: senha,
        data: {'nome': nome},
      );
      final user = resposta.user;
      if (user == null) return 'Não foi possível criar a conta.';
      if (user.identities != null && user.identities!.isEmpty) {
        return 'Já existe uma conta com esse e-mail.';
      }
      if (resposta.session == null) {
        return 'Conta criada. Confirme o e-mail antes de entrar.';
      }
      atual = _deAuth(user);
      if (!_descartado) notifyListeners();
      return null;
    } on AuthException catch (erro) {
      return mensagemAuth(erro);
    }
  }

  Usuario _deAuth(User user) {
    final meta = user.userMetadata;
    final nome = meta?['nome'];
    return Usuario(
      id: user.id,
      nome: nome is String && nome.trim().isNotEmpty ? nome.trim() : (user.email ?? 'Conta'),
      email: user.email ?? '',
      senhaHash: '',
    );
  }

  String? _validar({
    required String nome,
    required String email,
    required String senha,
  }) {
    final emailLimpo = email.trim().toLowerCase();
    if (nome.trim().length < 2) return 'Informe o nome.';
    if (!emailLimpo.contains('@') || !emailLimpo.contains('.')) {
      return 'Informe um e-mail válido.';
    }
    if (senha.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
    return null;
  }

  Future<String?> _entrarLocal({
    required String email,
    required String senha,
  }) async {
    final normalizado = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    final usuario = _usuarios(prefs).where((item) => item.email == normalizado).firstOrNull;
    if (usuario == null || usuario.senhaHash != hashSenha(senha)) {
      return 'E-mail ou senha incorretos.';
    }
    await prefs.setString(_chaveSessao, usuario.id);
    atual = usuario;
    if (!_descartado) notifyListeners();
    return null;
  }

  Future<String?> _cadastrarLocal({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = _usuarios(prefs);
    if (lista.any((usuario) => usuario.email == email)) {
      return 'Já existe uma conta com esse e-mail.';
    }

    final usuario = Usuario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nome: nome,
      email: email,
      senhaHash: hashSenha(senha),
    );
    lista.add(usuario);
    await prefs.setString(
      _chaveUsuarios,
      jsonEncode([for (final item in lista) item.toJson()]),
    );
    await prefs.setString(_chaveSessao, usuario.id);
    atual = usuario;
    if (!_descartado) notifyListeners();
    return null;
  }

  List<Usuario> _usuarios(SharedPreferences prefs) {
    final bruto = prefs.getString(_chaveUsuarios);
    if (bruto == null || bruto.isEmpty) return [];
    final lista = jsonDecode(bruto) as List<dynamic>;
    return [
      for (final item in lista) Usuario.fromJson(item as Map<String, dynamic>),
    ];
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope não encontrado');
    return scope!.notifier!;
  }
}
