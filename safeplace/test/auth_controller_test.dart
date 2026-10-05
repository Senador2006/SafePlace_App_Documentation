import 'package:flutter_test/flutter_test.dart';
import 'package:safeplace/services/auth_controller.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('duas contas nao compartilham o plano', () async {
    final auth = AuthController();
    final plano = PlanoController();
    addTearDown(auth.dispose);
    addTearDown(plano.dispose);

    expect(await auth.cadastrar(nome: 'Ana', email: 'ana@fiap.com', senha: '123456'), isNull);
    await plano.vincular(auth.atual!.id);
    await plano.assinarPro();
    final ana = auth.atual!.id;

    await auth.sair();
    await plano.desvincular();

    expect(await auth.cadastrar(nome: 'Bruno', email: 'bruno@fiap.com', senha: '123456'), isNull);
    await plano.vincular(auth.atual!.id);
    expect(plano.ehPro, isFalse);

    await auth.sair();
    await plano.desvincular();
    expect(await auth.entrar(email: 'ana@fiap.com', senha: '123456'), isNull);
    await plano.vincular(ana);
    expect(plano.ehPro, isTrue);
    expect(auth.atual!.id, ana);
  });

  test('nao cadastra o mesmo e-mail duas vezes', () async {
    final auth = AuthController();
    addTearDown(auth.dispose);
    expect(await auth.cadastrar(nome: 'Ana', email: 'ana@fiap.com', senha: '123456'), isNull);
    await auth.sair();
    expect(
      await auth.cadastrar(nome: 'Ana 2', email: 'ANA@fiap.com', senha: '123456'),
      'Já existe uma conta com esse e-mail.',
    );
  });
}
