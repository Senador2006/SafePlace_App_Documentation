import 'package:supabase_flutter/supabase_flutter.dart';

/// Projeto SafePlace no Supabase.
///
/// A URL é a do projeto, sem `/rest/v1`. A chave é a **anon public**
/// (o app pode levá-la). A `service_role` não entra aqui.
///
/// Dá para trocar na hora de rodar:
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
const urlArquivoSupabase = 'https://eyuqzvmntylymitebrvj.supabase.co';

const chaveArquivoSupabase =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5dXF6dm1udHlseW1pdGVicnZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTExNDg1NzksImV4cCI6MjEwNjcyNDU3OX0.QWL4jcJ85_YCpCiXElo_Eu2bfqcivZQGqIcLBWloxoc';

const urlSupabase = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: urlArquivoSupabase,
);

const chaveSupabase = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: chaveArquivoSupabase,
);

/// Fica verdadeiro depois de [iniciarSupabase]. Os testes não ligam isso
/// e continuam com a conta local.
var supabaseLigado = false;

Future<void> iniciarSupabase() async {
  if (urlSupabase.isEmpty || chaveSupabase.isEmpty) return;
  await Supabase.initialize(url: urlSupabase, anonKey: chaveSupabase);
  supabaseLigado = true;
}

SupabaseClient get clienteSupabase => Supabase.instance.client;
