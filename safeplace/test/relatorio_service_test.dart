import 'package:flutter_test/flutter_test.dart';
import 'package:safeplace/models/bairro.dart';
import 'package:safeplace/services/relatorio_service.dart';

void main() {
  const pinheiros = Bairro(
    id: 1,
    nome: 'Pinheiros',
    latitude: -23.56,
    longitude: -46.69,
    furtos: 40,
    roubos: 12,
    homicidios: 0,
  );
  const se = Bairro(
    id: 8,
    nome: 'Sé',
    latitude: -23.55,
    longitude: -46.63,
    furtos: 95,
    roubos: 50,
    homicidios: 2,
  );

  test('serie mensal soma o total oficial do bairro', () {
    final relatorio = RelatorioService.of(pinheiros, const [pinheiros, se]);
    final soma = relatorio.serieMensal.fold<int>(0, (total, mes) => total + mes);
    expect(soma, pinheiros.ocorrencias);
    expect(relatorio.maisComuns.map((crime) => crime.nome), ['Furtos', 'Roubos']);
    expect(relatorio.indice, 35);
  });

  test('resumo descreve a variacao entre os dois trimestres', () {
    expect(
      RelatorioService.resumoOcorrencias(100, 80),
      'As ocorrências diminuíram 20% em relação ao período anterior.',
    );
    expect(
      RelatorioService.resumoOcorrencias(100, 110),
      'As ocorrências aumentaram 10% em relação ao período anterior.',
    );
    expect(
      RelatorioService.resumoOcorrencias(10, 10),
      'As ocorrências permaneceram estáveis em relação ao período anterior.',
    );
  });

  test('indice 100 e o maior volume da base', () {
    final relatorio = RelatorioService.of(se, const [pinheiros, se]);
    expect(relatorio.indice, 100);
  });
}
