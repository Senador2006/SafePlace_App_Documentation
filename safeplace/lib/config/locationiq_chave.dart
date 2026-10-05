/// Token da LocationIQ (plano gratuito, sem cartão).
///
/// 1. Crie a conta em https://locationiq.com
/// 2. No painel, copie o Access Token (começa com `pk.`)
/// 3. Cole abaixo, ou rode o app com
///    `--dart-define=LOCATIONIQ_KEY=pk.seu_token`
///
/// A chave aparece na hora. Não precisa de pedido de aprovação.
const chaveArquivoLocationIq = 'pk.8a85fba42785acd98def719bb6b86ce0';

const chaveLocationIq = String.fromEnvironment(
  'LOCATIONIQ_KEY',
  defaultValue: chaveArquivoLocationIq,
);

const urlCadastroLocationIq = 'https://locationiq.com/';
